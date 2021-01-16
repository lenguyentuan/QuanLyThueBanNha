-- Đăng ký tài khoản
CREATE PROC sp_signup(@userName VARCHAR(40), @pw VARCHAR(40))
AS
BEGIN
	BEGIN TRY	
		SET @userName = LOWER(@userName);
    -- kiểm tra tài khoản đã tồn tại
		IF EXISTS(SELECT 1 FROM [dbo].[TaiKhoan] WHERE [UserName] = '')
		BEGIN
			THROW 51000, 'Tài khoản đã tồn tại.', 1;
			RETURN 0;
		END
		-- Tạo tài khoản
		INSERT INTO [dbo].[TaiKhoan]
		(
		  [UserName],
		  [MatKhau],
		  [UserRole]
		)
		VALUES
		( @userName, -- UserName - varchar(40)
		  @pw, -- MatKhau - char(40)
		  0   -- UserRole - tinyint
		)
		-- return
		RETURN 1;
   END TRY
	 BEGIN CATCH
			THROW;
	 END CATCH
END
GO	

-- Đăng nhập
ALTER PROC sp_login (
  @userName VARCHAR(40),
  @pw VARCHAR(40))
AS
BEGIN
	SET @userName = LOWER(@userName);
	DECLARE @role INT = 1;
  SELECT @role = [UserRole] FROM [dbo].[TaiKhoan]
	WHERE EXISTS(SELECT 1 FROM	[dbo].[TaiKhoan] WHERE [UserName] = @userName AND	[MatKhau] = @pw)
	-- đăng nhập thất bại nếu role = -1
	RETURN @role;
END;
GO

SELECT * FROM [dbo].[TaiKhoan]
EXEC [dbo].[sp_login]	 @userName = 'tuan25', @pw = 'Tuan12'
