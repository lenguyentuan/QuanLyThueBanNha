--Nhom03

USE QLThueBanNha
GO

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------*** DIRTY READ ***------------------------------
--Tinh huong 1 (Dirty Read)
create proc sp_ThayDoiGiaBan(@MaNha char(10),@MaChuNha char(10),@NVQL char(10),@NgayDang datetime,@Giabanmoi money)
as
begin tran
declare @Giabantoida money
set @Giabantoida = 20000000
UPDATE BaiDangBan 

SET Giaban = @Giabanmoi

WHERE MaChuNha = '001' and MaNha = '001' and NVQL = '004' and NgayDang = '2006-06-01'

waitfor delay '00:00:10'

if @Giabanmoi > @Giabantoida 
begin
raiserror ('Gia ban moi khong the lon hon gia ban toi da',17,1)
	ROLLBACK
end
else
begin
	COMMIT TRAN
end

exec sp_ThayDoiGiaBan '001','001','004','2006-06-01',50000000000
go

------------------------------------------------------------

--Tinh huong 2 (Dirty Read)
create proc sp_ThayDoiNgayHetHan(@MaNha char(10), @MaChuNha char(10),@NVQL char(10),@NgayDang datetime,@NgayHetHanMoi datetime)
as
BEGIN TRAN
declare @NgayHetHan datetime

select @NgayHetHan = BDB.NgayHetHan from BaiDangBan BDB where MaNha = @MaNha and MaChuNha = @MaChuNha and NVQL =@NVQL and NgayDang = @NgayDang

UPDATE BaiDangBan 
SET NgayHetHan = @NgayHetHanMoi
WHERE MaNha = '001' and MaChuNha = '001' and NVQL ='004' and NgayDang = '2006-06-01'
waitfor delay '00:00:10'
IF @NgayHetHanMoi < @NgayDang
begin
raiserror ('ngay het han nho hon ngay dang ',16,1)
rollback
end
else
begin
commit
end

exec sp_ThayDoiNgayHetHan '001','001','004','2006-06-01','2005-06-01'
go


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------*** PHANTOM ***------------------------------

--PROC thêm bài đăng bán
ALTER PROCEDURE Them_BaiDangBan
	@MaNha CHAR(10),
	@MaChuNha CHAR(10),
	@NVQL CHAR(10),
	@NgayDang DATETIME,
	@NgayHetHan DATETIME,
	@TinhTrang BIT,
	@GiaBan MONEY,
	@MoTa NVARCHAR(50)
AS
BEGIN
	IF(@NgayDang < @NgayHetHan)
		INSERT INTO BaiDangBan
		VALUES (@MaNha, @MaChuNha, @NVQL, @NgayDang, @NgayHetHan, @TinhTrang, @GiaBan, @MoTa)
	ELSE
		BEGIN
			PRINT N'Thời gian của bài đăng bán không hợp lệ'
			ROLLBACK
		END
END
GO

--PROC thêm hợp đồng
ALTER PROCEDURE Them_HopDong
	@MaHD CHAR(10),
	@MaNha CHAR(10),
	@NVLap CHAR(10),
	@MaKH CHAR(10),
	@NgayLap DATETIME,
	@NgayBatDau DATETIME,
	@NgayHetHan DATETIME,
	@GiaThueThucTe MONEY
AS
BEGIN
	IF((@NgayLap < @NgayBatDau) AND (@NgayBatDau < @NgayHetHan))
		INSERT INTO HopDong
		VALUES (@MaHD, @MaNha, @NVLap, @MaKH, @NgayLap, @NgayBatDau, @NgayHetHan, @GiaThueThucTe)
	ELSE
		BEGIN
			PRINT N'Thời gian của hợp đồng không hợp lệ'
			ROLLBACK
		END
END
GO

------------------------------------------------------------

--Tình huống 3 (Phantom): Nhân viên đang xem danh sách các bài đăng bán 
--thì người bán có thêm vào 1 bài đăng bán mới

----TRANSACTION 1
USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

SELECT * FROM BAIDANGBAN

WAITFOR DELAY '00:00:10'

SELECT * FROM BAIDANGBAN

COMMIT TRANSACTION

----TRANSACTION 2
USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
EXEC Them_BaiDangBan 'MN004', 'CN002', 'NV001', '1/1/2018', '7/5/2017', 1, 2000, N'Mô tả'
COMMIT TRANSACTION
GO

------------------------------------------------------------

--Tình huống 4 (Phantom): Nhân viên đang xem danh sách các hợp đồng 
--thì nhân viên khác có thêm vào một hợp đồng mới

----TRANSACTION 1

USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

SELECT * FROM HopDong

WAITFOR DELAY '00:00:10'

SELECT * FROM HopDong

COMMIT TRANSACTION

----TRANSACTION 2
USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
EXEC Them_HopDong 'HD008', 'MN002', 'NV002', 'KH001', '9/9/2020', '10/9/2020', '10/8/2020', 2000
GO
COMMIT TRANSACTION
GO


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------*** UNREPEATABLE READ ***------------------------------
GO
CREATE TABLE TAIKHOAN 
( 	TenDangNhap nchar(10), 
	MatKhau nchar(10),
	PRIMARY KEY (TenDangNhap)
)
--Tình huống 5 (Unrepeatable Read)
--T1
GO
CREATE PROC sp_DangNhap
(
	@TenDangNhap nchar(10),
	@MatKhau nchar(10)
)
AS
BEGIN TRAN
	SET TRAN ISOLATION LEVEL REPEATABLE READ
	IF(NOT EXISTS(SELECT * FROM TAIKHOAN WHERE TenDangNhap=@TenDangNhap AND MatKhau=@MatKhau))
	BEGIN 
		PRINT('TEN DANG NHAP HOAC MAT KHAU SAI');
		RETURN
	END
	WAITFOR DELAY '00:00:10'
	SELECT * FROM TAIKHOAN WHERE TenDangNhap=@TenDangNhap AND MatKhau=@MatKhau
	RAISERROR (N'DANG NHAP THANH CONG',16,1);
	
COMMIT TRAN

--T2
GO
CREATE PROC sp_DoiMatKhau
(
	@TenDangNhap nchar(10),
	@MatKhau nchar(10)
)
AS
BEGIN TRAN
	UPDATE TAIKHOAN SET MatKhau=@MatKhau WHERE TenDangNhap=@TenDangNhap
COMMIT TRAN

------------------------------------------------------------

--Tình Huống 6 (Unrepeatable Read)
GO
--T1:XEM NHÀ
CREATE PROC sp_XemNgayHetHan
(
	@NgayHetHan datetime
)
AS
BEGIN TRAN
	SET TRAN ISOLATION LEVEL REPEATABLE READ
	IF(NOT EXISTS(SELECT * FROM BaiDangBan WHERE NgayHetHan=@NgayHetHan))
	BEGIN
		PRINT N'NGÀY NHẬP KHÔNG TỒN TẠI'
	END
	WAITFOR DELAY '00:00:10'
	SELECT * FROM BaiDangBan WHERE NgayHetHan=@NgayHetHan

COMMIT TRAN

GO
--T2: CẬP NHẬT TÌNH TRẠNG NHÀ
CREATE PROC sp_CapNhat
(
	@MaNha nchar(10),
	@NgayHetHan datetime
)
AS
BEGIN TRAN
	UPDATE BaiDangBan SET NgayHetHan=@NgayHetHan WHERE MaNha=@MaNha
COMMIT TRAN
GO


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------*** DEADLOCK ***------------------------------

--Tình huống 7 (Conversion Deadlock): Nhân viên đang xem danh sách các hợp đồng và thêm 1 hợp đồng mới 
--thì nhân viên khác cũng xem danh sách và thêm vào 1 hợp đồng mới 
----TRANSACTION 1

USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

SELECT * FROM HopDong

WAITFOR DELAY '00:00:10'

EXEC Them_HopDong 'HD009', 'MN003', 'NV002', 'KH001', '9/9/2020', '10/9/2020', '11/11/2020', 2000

COMMIT TRANSACTION

----TRANSACTION 2

USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

SELECT * FROM HopDong

EXEC Them_HopDong 'HD010', 'MN003', 'NV002', 'KH001', '9/9/2020', '10/9/2020', '11/11/2020', 2000

COMMIT TRANSACTION
GO

------------------------------------------------------------

--Tình huống 8 (Cycle Deadlock): Nhân viên thêm 1 bài đăng bán mới và thêm 1 hợp đồng mới 
--thì nhân viên khác cũng thêm 1 hợp đồng mới và thêm 1 bài đăng bán mới 

----TRANSACTION 1
USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

EXEC Them_BaiDangBan 'MN001', 'CN002', 'NV001', '2/1/2018', '7/5/2019', 1, 2000, N'Mô tả'

WAITFOR DELAY '00:00:10'

EXEC Them_HopDong 'HD011', 'MN003', 'NV002', 'KH001', '9/9/2020', '10/9/2020', '11/11/2020', 2000

COMMIT TRANSACTION

----TRANSACTION 2

USE QLThueBanNha
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

EXEC Them_HopDong 'HD022', 'MN003', 'NV002', 'KH001', '9/9/2020', '10/9/2020', '11/11/2020', 2000

EXEC Them_BaiDangBan 'MN002', 'CN002', 'NV001', '3/1/2018', '7/5/2019', 1, 2000, N'Mô tả'

COMMIT TRANSACTION
GO


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------*** LOST UPDATE ***------------------------------
-- Tình huống 9 (Lost Update)
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @giabanmoi MONEY = (SELECT GiaBan FROM BaiDangBan WHERE MaBDB = 'MABDB1')
WAITFOR DELAY '00:00:20'
SET @giabanmoi = @giabanmoi * 1.1
UPDATE BaiDangBan SET GiaBan = @giabanmoi WHERE MaBDB = 'MABDB1'
COMMIT TRAN

------------------------------------------------------------

--Tình huống 10 (Lost Update)
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @luongmoi MONEY = (SELECT Luong FROM NhanVien WHERE MaNV = 'MANV1')
WAITFOR DELAY '00:00:20'
SET @luongmoi = @luongmoi * 2
UPDATE NhanVien SET Luong = @luongmoi WHERE MaNV = 'MANV1'
COMMIT TRAN
