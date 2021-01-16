CREATE DATABASE QLThueBanNha
GO
USE QLThueBanNha
GO

------------------------------

CREATE TABLE Nha
(
	MaNha CHAR(10),
	MaLoai CHAR(10),
	MaChuNha CHAR(10),
	MaChiNhanh CHAR(10),
	Duong NCHAR(50),
	Quan NCHAR(50),
	ThanhPho NCHAR(50),
	KhuVuc NCHAR(50),
	SoLuongPhong INT,
	PRIMARY KEY (MaNha)
)
GO

CREATE TABLE LoaiNha
(
	MaLoai CHAR(10),
	TenLoai NCHAR(50),
	PRIMARY KEY (MaLoai)
)
GO

CREATE TABLE BaiDangBan
(
	MaNha CHAR(10),
	MaChuNha CHAR(10),
	NVQL CHAR(10),
	NgayDang DATETIME,
	NgayHetHan DATETIME,
	TinhTrang BIT,
	GiaBan MONEY,
	MoTa NCHAR(256),
	PRIMARY KEY (MaNha, MaChuNha, NVQL, NgayDang)
)
GO

CREATE TABLE BaiDangThue
(
	MaNha CHAR(10),
	MaChuNha CHAR(10),
	NVQL CHAR(10),
	NgayDang DATETIME,
	NgayHetHan DATETIME,
	TinhTrang BIT,
	GiaThue MONEY,
	PRIMARY KEY (MaNha, MaChuNha, NVQL, NgayDang)
)
GO

CREATE TABLE LichSuXemNha
(
	MaNha CHAR(10),
	MaChuNha CHAR(10),
	NVQL CHAR(10),
	NgayDang DATETIME,
	NgayXem DATE,
	PRIMARY KEY (MaNha, MaChuNha, NVQL, NgayDang, NgayXem)
)
GO

CREATE TABLE ChuNha
(
	MaChuNha CHAR(10),
	TenChuNha NCHAR(50),
	DiaChi NCHAR(50),
	SDT NCHAR(11),
	PRIMARY KEY (MaChuNha)
)
GO

CREATE TABLE NhanVien
(
	MaNV CHAR(10),
	TenNV NCHAR(50),
	DiaChi NCHAR(256),
	SDT NCHAR(11),
	GioiTinh BIT,
	NgaySinh DATE,
	Luong MONEY,
	MaChiNhanh CHAR(10),
	PRIMARY KEY (MaNV)
)
GO

CREATE TABLE ChiNhanh
(
	MaChiNhanh CHAR(10),
	SDT NCHAR(11),
	FAX NCHAR(11),
	Duong NCHAR(50),
	Quan NCHAR(50),
	ThanhPho NCHAR(50),
	KhuVuc NCHAR(50),
	PRIMARY KEY (MaChiNhanh)
)
GO

CREATE TABLE KhachHang
(
	MaKH CHAR(10),
	TenKH NCHAR(50),
	DiaChi NCHAR(256),
	SDT NCHAR(11),
	MaChiNhanh CHAR(10),
	NVQL CHAR(10),
	LoaiNhaYeuCau CHAR(10),
	PRIMARY KEY (MaKH)
)
GO

CREATE TABLE NhanXet
(
	MaNha CHAR(10),
	MaKH CHAR(10),
	NgayNhanXet DATE,
	MoTa NCHAR(256),
	PRIMARY KEY (MaNha, MaKH, NgayNhanXet)
)
GO

CREATE TABLE HopDong
(
	MaHD CHAR(10),
	MaNha CHAR(10),
	NVLap CHAR(10),
	MaKH CHAR(10),
	NgayLap DATETIME,
	NgayBatDau DATETIME,
	NgayHetHan DATETIME,
	GiaThueThucTe MONEY,
	PRIMARY KEY (MaHD)
)
GO

CREATE TABLE TaiKhoan(
	UserName VARCHAR(40) PRIMARY KEY,
	MatKhau CHAR(40),
	UserRole TINYINT DEFAULT(0) -- role = 1 là Admin
)
GO	

------------------------------

ALTER TABLE BaiDangBan ADD FOREIGN KEY (MaNha) REFERENCES Nha (MaNha)
ALTER TABLE BaiDangThue ADD FOREIGN KEY (MaNha) REFERENCES Nha (MaNha)
ALTER TABLE LichSuXemNha ADD FOREIGN KEY (MaNha) REFERENCES Nha (MaNha)
ALTER TABLE NhanXet ADD FOREIGN KEY (MaNha) REFERENCES Nha (MaNha)
ALTER TABLE HopDong ADD FOREIGN KEY (MaNha) REFERENCES Nha (MaNha)
GO
ALTER TABLE Nha ADD FOREIGN KEY (MaLoai) REFERENCES LoaiNha (MaLoai)
GO
ALTER TABLE LichSuXemNha ADD FOREIGN KEY (MaNha, MaChuNha, NVQL, NgayDang) REFERENCES BaiDangBan (MaNha, MaChuNha, NVQL, NgayDang)
GO
ALTER TABLE LichSuXemNha ADD FOREIGN KEY (MaNha, MaChuNha, NVQL, NgayDang) REFERENCES BaiDangThue (MaNha, MaChuNha, NVQL, NgayDang)
GO
ALTER TABLE Nha ADD FOREIGN KEY (MaChuNha) REFERENCES ChuNha (MaChuNha)
ALTER TABLE BaiDangBan ADD FOREIGN KEY (MaChuNha) REFERENCES ChuNha (MaChuNha)
ALTER TABLE BaiDangThue ADD FOREIGN KEY (MaChuNha) REFERENCES ChuNha (MaChuNha)
ALTER TABLE LichSuXemNha ADD FOREIGN KEY (MaChuNha) REFERENCES ChuNha (MaChuNha)
GO
ALTER TABLE BaiDangThue ADD FOREIGN KEY (NVQL) REFERENCES NhanVien (MaNV)
ALTER TABLE BaiDangBan ADD FOREIGN KEY (NVQL) REFERENCES NhanVien (MaNV)
ALTER TABLE LichSuXemNha ADD FOREIGN KEY (NVQL) REFERENCES NhanVien (MaNV)
ALTER TABLE KhachHang ADD FOREIGN KEY (NVQL) REFERENCES NhanVien (MaNV)
ALTER TABLE HopDong ADD FOREIGN KEY (NVLap) REFERENCES NhanVien (MaNV)
GO
ALTER TABLE Nha ADD FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh (MaChiNhanh)
ALTER TABLE NhanVien ADD FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh (MaChiNhanh)
ALTER TABLE KhachHang ADD FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh (MaChiNhanh)
GO
ALTER TABLE NhanXet ADD FOREIGN KEY (MaKH) REFERENCES KhachHang (MaKH)
ALTER TABLE HopDong ADD FOREIGN KEY (MaKH) REFERENCES KhachHang (MaKH)
GO
