

-- PHẦN 1: KHỞI TẠO DATABASE & BẢNG
-- ======================================================================================
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QL_LuongNV')
    DROP DATABASE QL_LuongNV;
GO
CREATE DATABASE QL_LuongNV;
GO
USE QL_LuongNV;
GO

-- 1.1. BẢNG DANH MỤC & NHÂN SỰ
CREATE TABLE PhongBan (
    MaPB int identity(1,1) primary key,
    TenPB nvarchar(50) not null Unique,
    NgayThanhLap Date Default GetDate()
);

CREATE TABLE ChucVu (
    MaCV int identity(1,1) primary key,
    TenCV nvarchar(50) not null unique,
    HeSoLuong Decimal(4,2) Check(HeSoLuong BETWEEN 1 AND 10)
);

CREATE TABLE NhanVien (
    MaNV int identity(1,1) primary key,
    HoTen nvarchar(40) not null,
    NgaySinh Date Check(NgaySinh < GetDate()),
    GioiTinh  nvarchar(5) DEFAULT N'Nam',
    DiaChi nvarchar(50),
    DienThoai nvarchar(15),
    Email nvarchar(60) unique,
    TrangThai nvarchar(25) DEFAULT N'Đang làm',
    MaCV int,
    MaPB int,
    LuongHienTai decimal(18,2), 
    CONSTRAINT FK_MaCV_NhanVien FOREIGN KEY (MaCV) REFERENCES ChucVu(MaCV),
    CONSTRAINT FK_MaPB_NhanVien FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);

CREATE TABLE HopDong (
    MaHD int identity(1,1) primary key,
    MaNV int,
    NgayBatDau Date not null,
    NgayKetThuc Date,
    LoaiHD nvarchar(50) Check(LoaiHD in(N'Có thời hạn',N'Không thời hạn')),
    LuongCoBan decimal(18,2) check (LuongCoBan > 0),
    GhiChu nvarchar(200),
    CONSTRAINT FK_MaNV_HopDong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- 1.2. BẢNG LƯƠNG & CÔNG
CREATE TABLE BangChamCong (
    MaCC int identity(1,1) primary key,
    MaNV int,
    Ngay Date not null,
    NgayCong decimal(4,2) default 1.0 check(NgayCong BETWEEN 0 AND 1),
    GioTangCa decimal(5,2) default 0 check (GioTangCa >= 0),
    CONSTRAINT FK_MaNV_BangChamCong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

CREATE TABLE PhuCap (
    MaPC int identity(1,1) primary key,
    MaNV int,
    LoaiPhuCap nvarchar(50),
    SoTien decimal(18,2) check(SoTien>=0),
    CONSTRAINT FK_MaNV_PhuCap FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

CREATE TABLE ThuongPhat (
    MaTP int identity(1,1) primary key,
    MaNV int,
    Thangg int check(Thangg BETWEEN 1 AND 12),
    Namm int check(Namm >=2000),
    Loai nvarchar(20) check (Loai in(N'Thưởng',N'Phạt')),
    SoTien decimal(18,2) check(SoTien>0),
    LyDo nvarchar(200),
    CONSTRAINT FK_MaNV_ThuongPhat FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

CREATE TABLE LuongCoBan (
    MaLCB int identity(1,1) primary key,
    MaCV int,
    MucLuong decimal(18,2) check (MucLuong>0),
    CONSTRAINT Fk_MaCV_LuongCoBan FOREIGN KEY (MaCV) REFERENCES ChucVu(MaCV)
);

CREATE TABLE BangLuong (
    MaBangLuong int identity(1,1) primary key,
    MaNV int,
    Thang int check(Thang BETWEEN 1 AND 12),
    Nam int check(Nam >= 2000),
    LuongCoBan decimal(18,2),
    TongPhuCap decimal(18,2),
    TongThuongPhat decimal(18,2),
    TongGioTangCa decimal(10,2),
    -- Cột tính toán tự động: Lương thực nhận
    LuongThucNhan AS (LuongCoBan + ISNULL(TongPhuCap,0) + ISNULL(TongThuongPhat,0) + ISNULL(TongGioTangCa,0) * 50000),
    CONSTRAINT FK_MANV_BangLuong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- 1.3. BẢNG HỆ THỐNG & LOG
CREATE TABLE Roles (
    MaRole INT IDENTITY(1,1) PRIMARY KEY,
    TenRole NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE TaiKhoan (
    TenDangNhap nvarchar(50) not null primary key,
    MatKhau nvarchar(100) not null,
    MaNV int,
    Quyen nvarchar(20) default N'User',
    MaRole INT, 
    CONSTRAINT FK_MaNV_TaiKhoan FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_TaiKhoan_Roles FOREIGN KEY (MaRole) REFERENCES Roles(MaRole)
);

CREATE TABLE LichSuXoaNhanVien 
(
	ID INT IDENTITY(1,1) PRIMARY KEY, 
	MaNV INT, 
	HoTen NVARCHAR(40), 
	NgayXoa DATETIME, 
	LyDo NVARCHAR(200)
);
CREATE TABLE LichSuTaiKhoan 
(
	ID INT IDENTITY(1,1) PRIMARY KEY, 
	MaNV INT, TenDangNhap NVARCHAR(50),
	NgayTao DATETIME DEFAULT GETDATE()
);
CREATE TABLE LuongCoBanLog 
(
	ID INT IDENTITY(1,1) PRIMARY KEY, 
	MaCV INT, MucLuongCu DECIMAL(18,2), 
	MucLuongMoi DECIMAL(18,2), 
	NgayCapNhat DATETIME DEFAULT GETDATE()
);
CREATE TABLE Log_ChamCong (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    HanhDong NVARCHAR(10), MaNV INT, Ngay DATE,
    NgayCong_Cu DECIMAL(4,2), NgayCong_Moi DECIMAL(4,2),
    GioTangCa_Cu DECIMAL(5,2), GioTangCa_Moi DECIMAL(5,2),
    ThoiGian DATETIME DEFAULT GETDATE(), NguoiThucHien NVARCHAR(100) DEFAULT SUSER_SNAME()
);
GO

-- PHẦN 2: DỮ LIỆU MẪU CẤU HÌNH
-- ======================================================================================
INSERT INTO Roles (TenRole) 
VALUES (N'Admin'), (N'NhanSu'), (N'KeToan'), (N'NhanVien');

INSERT INTO PhongBan(TenPB) 
VALUES (N'Phòng Nhân Sự'), (N'Phòng Kế Toán'), (N'Phòng IT'), (N'Phòng Kinh Doanh'), (N'Phòng Marketing'), (N'Phòng Hành Chính');

INSERT INTO ChucVu(TenCV,HeSoLuong) 
VALUES (N'Nhân viên',1.20), (N'Trưởng phòng',2.00), (N'Giám đốc',3.50), (N'Phó phòng', 1.70), (N'Kế toán trưởng', 2.20);

INSERT INTO LuongCoBan(MaCV, MucLuong)
VALUES (1, 8000000), (2, 12000000), (3, 20000000), (4, 10000000), (5, 13000000);
GO

-- PHẦN 3: CÁC HÀM (FUNCTIONS)
-- ======================================================================================

-- [PHÚC] Tính tổng phụ cấp
CREATE FUNCTION fn_TongPhuCap_NV(@MaNV int) 
RETURNS decimal(18,2)
AS  
BEGIN
    DECLARE @Tong decimal(18,2);
	SELECT @Tong = Sum(SoTien) 
	FROM PhuCap
	WHERE MaNV = @MaNV; 
	RETURN ISNULL(@Tong,0);
END;
GO

-- [PHÚC] Tính tổng thưởng phạt lịch sử
CREATE FUNCTION fn_TongThuongPhat_NV_LichSu(@MaNV INT) 
RETURNS DECIMAL(18,2) 
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    SELECT @Tong = SUM(
		CASE 
			WHEN Loai = N'Thưởng' 
		THEN SoTien 
			WHEN Loai = N'Phạt' 
		THEN -SoTien 
		END)
    FROM ThuongPhat WHERE MaNV = @MaNV;
    RETURN ISNULL(@Tong,0);
END;
GO

-- [PHÚC] Kiểm tra hợp đồng active
CREATE FUNCTION fn_HopDongConHieuLuc(@MaNV int) 
RETURNS bit
AS
BEGIN 
    IF EXISTS(
		SELECT 1
		FROM HopDong 
		WHERE MaNV = @MaNV AND (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())) 
		RETURN 1; 
    RETURN 0; 
END;
GO

-- [PHÚC] Thống kê HĐ hết hạn
CREATE FUNCTION fn_SoLuongHopDongHetHan()
RETURNS INT
AS
BEGIN 
    RETURN (SELECT COUNT(*) FROM HopDong WHERE NgayKetThuc IS NOT NULL AND NgayKetThuc < GETDATE()); 
END;
GO

-- [PHÚC] Hàm tính thâm niên (Số tháng làm việc)
-- Dùng để: Xét duyệt tăng lương hoặc thưởng thâm niên
CREATE FUNCTION fn_TinhThamNien(@MaNV INT) RETURNS INT AS
BEGIN
    DECLARE @NgayVaoLam DATE;
    -- Lấy ngày bắt đầu của hợp đồng đầu tiên
    SELECT TOP 1 @NgayVaoLam = NgayBatDau 
	FROM HopDong 
	WHERE MaNV = @MaNV 
	ORDER BY NgayBatDau ASC;
    
    IF @NgayVaoLam IS NULL RETURN 0;
    
    RETURN DATEDIFF(MONTH, @NgayVaoLam, GETDATE());
END;
GO

-- [PHÚC] Báo cáo chi phí phụ cấp
CREATE FUNCTION fn_TongPhuCapLoai(@LoaiPhuCap NVARCHAR(50) = NULL) RETURNS DECIMAL(18,2) AS
BEGIN 
    DECLARE @Tong DECIMAL(18,2); SELECT @Tong = SUM(SoTien) FROM PhuCap WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap; RETURN ISNULL(@Tong, 0); 
END;
GO






-- ======================================================================================

-- [TRƯỜNG] Các hàm tiện ích
CREATE FUNCTION fn_LayMaNhanVienTheoEmail(@Email NVARCHAR(60)) 
RETURNS INT AS
BEGIN
    DECLARE @MaNV INT;
	SELECT TOP 1 @MaNV = MaNV 
	FROM NhanVien WHERE Email = @Email; 
	RETURN ISNULL(@MaNV, 0);
END;
GO
CREATE FUNCTION fn_KiemTraNhanVienTonTai(@MaNV INT)
RETURNS BIT AS
	BEGIN 
		RETURN 
			(
			SELECT CASE WHEN EXISTS(
				SELECT 1 
				FROM NhanVien 
				WHERE MaNV = @MaNV) 
			THEN 1 
			ELSE 0 
			END); 
	END;
GO

CREATE FUNCTION fn_LayQuyenTaiKhoan(@TenDangNhap NVARCHAR(50)) 
RETURNS NVARCHAR(20) AS
	BEGIN 
		DECLARE @Quyen NVARCHAR(20); 
		SELECT @Quyen = Quyen 
		FROM TaiKhoan 
		WHERE TenDangNhap = @TenDangNhap; 
		RETURN ISNULL(@Quyen, N'User'); 
	END;
GO

CREATE FUNCTION fn_DemNhanVienTrongPhong(@MaPB INT) 
RETURNS INT AS
	BEGIN 
		RETURN 
			(SELECT COUNT(*) 
			FROM NhanVien 
			WHERE MaPB = @MaPB); 
	END;
GO

CREATE FUNCTION fn_TrungBinhHeSoLuong() 
RETURNS DECIMAL(5,2) AS
	BEGIN 
		RETURN 
			(SELECT AVG(HeSoLuong)
			FROM ChucVu); 
	END;
GO
-- ======================================================================================

-- [TUẤN] Các hàm chấm công
CREATE FUNCTION fn_TongGioTangCa_Thang(@MaNV_BangChamCong INT, @Thang_BangLuong INT, @Nam_BangLuong INT) RETURNS DECIMAL(10,2) AS
BEGIN
    DECLARE @TongGio DECIMAL(10,2);
    SELECT @TongGio = SUM(GioTangCa) FROM BangChamCong WHERE MaNV = @MaNV_BangChamCong AND MONTH(Ngay) = @Thang_BangLuong AND YEAR(Ngay) = @Nam_BangLuong;
    RETURN ISNULL(@TongGio, 0);
END;
GO
CREATE FUNCTION fn_TinhTongNgayCong(@MaNV_Input INT, @Thang_Input INT, @Nam_Input INT) RETURNS DECIMAL(10,2) AS
BEGIN
    DECLARE @TongNgayCong DECIMAL(10,2);
    SELECT @TongNgayCong = SUM(NgayCong) FROM BangChamCong WHERE MaNV = @MaNV_Input AND MONTH(Ngay) = @Thang_Input AND YEAR(Ngay) = @Nam_Input;
    RETURN ISNULL(@TongNgayCong, 0);
END;
GO
CREATE FUNCTION fn_KiemTraChamCongHopLe(@MaNV_Input INT, @Ngay_Input DATE, @NgayCong DECIMAL(4,2), @GioTangCa DECIMAL(5,2)) RETURNS BIT AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV_Input) RETURN 0;
    IF @Ngay_Input > GETDATE() OR @Ngay_Input < DATEADD(YEAR, -1, GETDATE()) RETURN 0;
    IF @NgayCong NOT IN (0, 0.5, 1.0) RETURN 0;
    IF @GioTangCa < 0 OR @GioTangCa > 12 RETURN 0;
    RETURN 1;
END;
GO
CREATE FUNCTION fn_TinhTyLeDiLam(@MaNV_Input INT, @Thang_Input INT, @Nam_Input INT) RETURNS DECIMAL(5,2) AS
BEGIN
    DECLARE @NgayLamViec_TieuChuan DECIMAL(10,2) = 26;
    DECLARE @TongNgayCong DECIMAL(10,2);
    SET @TongNgayCong = dbo.fn_TinhTongNgayCong(@MaNV_Input, @Thang_Input, @Nam_Input);
    IF @NgayLamViec_TieuChuan > 0 RETURN (@TongNgayCong * 100.0) / @NgayLamViec_TieuChuan;
    RETURN 0;
END;
GO
-- ======================================================================================

-- [TÂM] Các hàm lương thưởng
CREATE FUNCTION fn_LayLuongCoBan_NV(@MaNV INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @LuongCoBan DECIMAL(18,2);
    SELECT TOP 1 @LuongCoBan = h.LuongCoBan FROM HopDong h WHERE h.MaNV = @MaNV AND h.NgayBatDau <= GETDATE() AND (h.NgayKetThuc IS NULL OR h.NgayKetThuc >= GETDATE()) ORDER BY h.NgayBatDau DESC;
    RETURN ISNULL(@LuongCoBan, 0);
END
GO
CREATE FUNCTION fn_TinhLuongThucNhan_Tam(@MaNV INT, @Thang INT, @Nam INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @LuongThucNhan DECIMAL(18,2);
    SELECT @LuongThucNhan = LuongThucNhan FROM BangLuong WHERE MaNV = @MaNV AND Thang = @Thang AND Nam = @Nam;
    RETURN ISNULL(@LuongThucNhan,0);
END
GO
CREATE FUNCTION fn_TongThuongPhat_NV_Thang(@MaNV INT, @Thangg INT, @Namm INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    SELECT @Tong = ISNULL(SUM(CASE WHEN Loai = N'Thưởng' THEN SoTien WHEN Loai = N'Phạt' THEN -SoTien ELSE 0 END), 0)
    FROM ThuongPhat WHERE MaNV = @MaNV AND Thangg = @Thangg AND Namm = @Namm;
    RETURN @Tong;
END
GO

-- PHẦN 4: THỦ TỤC (STORED PROCEDURES)
-- ======================================================================================

-- [PHÚC] Quản lý nhân sự,Hợp đồng, Phụ cấp,....
CREATE PROCEDURE sp_AddNhanVien @HoTen NVARCHAR(40), @NgaySinh DATE, @GioiTinh NVARCHAR(5), @DiaChi NVARCHAR(50), @DienThoai NVARCHAR(15), @Email NVARCHAR(60), @MaPB INT, @MaCV INT
AS 
	BEGIN 
		SET NOCOUNT ON; 
		IF @Email IS NOT NULL AND EXISTS (
			SELECT 1 
			FROM NhanVien 
			WHERE Email = @Email)
		BEGIN RAISERROR(N'Email đã tồn tại',16,1); 
		RETURN; 
	END
	INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV) VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV); END;
GO

CREATE OR ALTER PROCEDURE sp_BaoCaoThamNien
AS
BEGIN
    SELECT 
        nv.MaNV,
        nv.HoTen,
        pb.TenPB,
        cv.TenCV,
        (SELECT MIN(NgayBatDau) FROM HopDong WHERE MaNV = nv.MaNV) AS NgayGiaNhap,
        
        dbo.fn_TinhThamNien(nv.MaNV) AS SoThangLamViec,
        
        CASE 
            WHEN dbo.fn_TinhThamNien(nv.MaNV) < 12 THEN N'Newbie (Dưới 1 năm)'
            WHEN dbo.fn_TinhThamNien(nv.MaNV) BETWEEN 12 AND 35 THEN N'Junior (1-3 năm)'
            WHEN dbo.fn_TinhThamNien(nv.MaNV) BETWEEN 36 AND 60 THEN N'Senior (3-5 năm)'
            ELSE N'Loyal (Trên 5 năm)'
        END AS CapDo,

        (dbo.fn_TinhThamNien(nv.MaNV) / 12) * 500000 AS ThuongDeXuat

    FROM NhanVien nv
    LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
    LEFT JOIN ChucVu cv ON nv.MaCV = cv.MaCV
    WHERE nv.TrangThai = N'Đang làm'
    ORDER BY dbo.fn_TinhThamNien(nv.MaNV) DESC; 
END;
GO

CREATE PROCEDURE sp_ThemHopDong @MaNV int, @NgayBatDau date, @NgayKetThuc date = null, @LoaiHD nvarchar(50), @Luongcoban decimal(18,2), @Ghichu nvarchar(200) = null 
AS 
	BEGIN 
		SET NOCOUNT ON; 
		IF EXISTS (
			SELECT 1 
			FROM HopDong 
			WHERE MaNV = @MaNV AND ((NgayKetThuc IS NOT NULL AND NgayKetThuc > GETDATE()) OR LoaiHD = N'Không thời hạn')) 
		BEGIN RAISERROR(N'Nhân viên này đang có hợp đồng còn hiệu lực!',16,1);
		RETURN;
		END
	INSERT INTO HopDong(MaNV,NgayBatDau,NgayKetThuc,LoaiHD,LuongCoBan,GhiChu) VALUES (@MaNV,@NgayBatDau,@NgayKetThuc,@LoaiHD,@Luongcoban,@Ghichu); END;
GO

CREATE PROCEDURE sp_ThemPhuCap @MaNV INT, @LoaiPhuCap NVARCHAR(50), @SoTien DECIMAL(18,2)
AS 
	BEGIN 
		SET NOCOUNT ON;
		IF NOT EXISTS (
			SELECT 1
			FROM NhanVien 
			WHERE MaNV = @MaNV) 
		BEGIN RAISERROR(N'Nhân viên không tồn tại!',16,1); 
		RETURN; 
	END
	INSERT INTO PhuCap(MaNV,LoaiPhuCap,SoTien) VALUES(@MaNV,@LoaiPhuCap,@SoTien); END;
GO

CREATE PROCEDURE sp_QuanLyLuongCoBan @HanhDong NVARCHAR(10), @MaCV INT, @MucLuong DECIMAL(18,2) = NULL
AS 
	BEGIN 
	SET NOCOUNT ON; 
		IF @HanhDong = N'Thêm' 
			INSERT INTO LuongCoBan(MaCV,MucLuong) 
			VALUES (@MaCV,@MucLuong);
		ELSE IF @HanhDong = N'Sửa' 
			UPDATE LuongCoBan 
			SET MucLuong = @MucLuong 
			WHERE MaCV = @MaCV;
		ELSE IF @HanhDong = N'Xóa' 
			DELETE FROM LuongCoBan 
			WHERE MaCV = @MaCV;
	END;
GO

CREATE PROCEDURE sp_DanhSachHopDongNV @MaNV int = null
AS 
BEGIN 
SELECT * 
FROM HopDong 
WHERE @MaNV IS NULL OR MaNV = @MaNV; 
END;
GO

CREATE PROCEDURE sp_TongPhuCapTheoLoai @LoaiPhuCap nvarchar(50) = null 
AS 
	BEGIN 
		SELECT LoaiPhuCap, SUM(SoTien) as TongPhuCap
		FROM PhuCap
		WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap 
		GROUP BY LoaiPhuCap; 
	END;
GO
-- [PHÚC] Quy trình Tăng lương hàng loạt (Theo %)
-- Dùng khi: Công ty tăng lương định kỳ hằng năm (VD: Tăng 5% cho toàn bộ nhân viên)
CREATE PROCEDURE sp_TangLuongHangLoat @PhanTramTang DECIMAL(5,2) AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
            -- Cập nhật lương trong Hợp đồng
            UPDATE HopDong 
            SET LuongCoBan = LuongCoBan * (1 + @PhanTramTang / 100)
            WHERE NgayKetThuc IS NULL OR NgayKetThuc > GETDATE();

            -- Cập nhật lương hiện tại trong NhanVien
            UPDATE NhanVien
            SET LuongHienTai = LuongHienTai * (1 + @PhanTramTang / 100)
            WHERE TrangThai = N'Đang làm';
        COMMIT TRAN;
        PRINT N'Đã tăng lương thành công cho toàn bộ nhân viên!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- [PHÚC] Quy trình Thưởng thâm niên tự động
-- Dùng để: Tự động thêm tiền thưởng vào bảng ThuongPhat cho NV làm > 5 năm
CREATE PROCEDURE sp_ThuongThamNienTuDong AS
BEGIN
    INSERT INTO ThuongPhat(MaNV, Loai, SoTien, LyDo, Thangg, Namm)
    SELECT MaNV, N'Thưởng', 1000000, N'Thưởng thâm niên > 5 năm', MONTH(GETDATE()), YEAR(GETDATE())
    FROM NhanVien
    WHERE dbo.fn_TinhThamNien(MaNV) >= 60; 
    
    PRINT N'Đã cộng thưởng thâm niên.';
END;
GO

CREATE OR ALTER PROCEDURE sp_XoaNhanVien_ToanBo
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            -- 1. Xóa Tài khoản đăng nhập (Nếu có)
            DELETE FROM TaiKhoan WHERE MaNV = @MaNV;
            
            -- 2. Xóa dữ liệu Lương & Chấm công
            DELETE FROM BangLuong WHERE MaNV = @MaNV;
            DELETE FROM BangChamCong WHERE MaNV = @MaNV;
            
            -- 3. Xóa Phụ cấp & Thưởng phạt
            DELETE FROM PhuCap WHERE MaNV = @MaNV;
            DELETE FROM ThuongPhat WHERE MaNV = @MaNV;
            
            -- 4. Xóa Hợp đồng
            DELETE FROM HopDong WHERE MaNV = @MaNV;
            
            -- 5. Xóa các log liên quan (nếu cần thiết, tùy bảng log của bạn)
            
            -- 6. Cuối cùng mới được xóa Nhân viên
            DELETE FROM NhanVien WHERE MaNV = @MaNV;
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Ném lỗi ra để C# bắt được
        THROW;
    END CATCH
END;
GO
-- ======================================================================================

-- [TRƯỜNG] Quản lý hệ thống
CREATE PROCEDURE sp_TaoTaiKhoan @TenDangNhap NVARCHAR(50), @MatKhau NVARCHAR(100), @MaNV INT, @Quyen NVARCHAR(20) = N'User', @MaRole INT = 4 
AS 
	BEGIN 
	SET NOCOUNT ON; 
	IF NOT EXISTS (
			SELECT 1 
			FROM NhanVien 
			WHERE MaNV=@MaNV) 
		BEGIN RAISERROR (N'Nhân viên không tồn tại',16,1); 
		RETURN; 
	END 

	IF EXISTS (
			SELECT 1 
			FROM TaiKhoan 
			WHERE TenDangNhap=@TenDangNhap) 
		BEGIN RAISERROR (N'Tên đăng nhập đã tồn tại',16,1); 
		RETURN; 
	END 

	IF @MaRole IS NULL 
			SELECT @MaRole = MaRole 
			FROM Roles 
			WHERE TenRole = @Quyen; 
		INSERT INTO TaiKhoan(TenDangNhap,MatKhau,MaNV,Quyen,MaRole) 
		VALUES(@TenDangNhap,@MatKhau,@MaNV,@Quyen,@MaRole);
	END;
GO

CREATE PROCEDURE sp_CapNhatTrangThaiNV 
AS 
	BEGIN 
		UPDATE NhanVien 
		SET TrangThai = N'Nghỉ việc' 
			WHERE MaNV NOT IN (
			SELECT MaNV 
			FROM HopDong 
			WHERE (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())); 
	END;
GO

CREATE PROCEDURE sp_QuanLyPhongBan @ThaoTac NVARCHAR(10), @MaPB INT = NULL, @TenPB NVARCHAR(50) = NULL 
AS 
	BEGIN 
		IF @ThaoTac = 'THEM' 
			INSERT INTO PhongBan(TenPB) 
			VALUES(@TenPB); 
		ELSE IF @ThaoTac = 'SUA' 
			UPDATE PhongBan 
			SET TenPB = @TenPB 
			WHERE MaPB = @MaPB; 
		ELSE IF @ThaoTac = 'XOA' 
			DELETE FROM PhongBan 
			WHERE MaPB = @MaPB; 
	END;
GO
CREATE PROCEDURE sp_QuanLyChucVu @ThaoTac NVARCHAR(10), @MaCV INT = NULL, @TenCV NVARCHAR(50) = NULL, @HeSoLuong DECIMAL(4,2) = NULL
AS
	BEGIN
		IF @ThaoTac = 'THEM' 
			INSERT INTO ChucVu(TenCV, HeSoLuong)
			VALUES(@TenCV, @HeSoLuong);
		ELSE IF @ThaoTac = 'SUA' 
			UPDATE ChucVu 
			SET TenCV = @TenCV, HeSoLuong = @HeSoLuong 
			WHERE MaCV = @MaCV; 
		ELSE IF @ThaoTac = 'XOA' 
			DELETE FROM ChucVu
			WHERE MaCV = @MaCV; 
	END;
GO

CREATE PROCEDURE sp_TaoBackup_QLLuong 
AS 
	BEGIN 
		DECLARE @File NVARCHAR(300); 
		SET @File = 'D:\Backup_QLLuong\QL_Luong_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak'; 
		BACKUP DATABASE QL_LuongNV TO DISK = @File WITH INIT, FORMAT, 
		NAME = 'Backup tu dong CSDL QL_Luong'; 
	END;
GO

-- [TUẤN] Tính lương
CREATE PROCEDURE sp_TinhBangLuong_Thang @Thang_BangLuong INT, @Nam_BangLuong INT
AS BEGIN SET NOCOUNT ON; DELETE FROM BangLuong WHERE Thang = @Thang_BangLuong AND Nam = @Nam_BangLuong;
INSERT INTO BangLuong (MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
SELECT nv.MaNV, @Thang_BangLuong, @Nam_BangLuong, ISNULL(hd.LuongCoBan, ISNULL(lcb.MucLuong, 0)), ISNULL((SELECT SUM(SoTien) FROM PhuCap pc WHERE pc.MaNV = nv.MaNV), 0), ISNULL((SELECT SUM(CASE WHEN tp.Loai = N'Thưởng' THEN tp.SoTien WHEN tp.Loai = N'Phạt' THEN -tp.SoTien END) FROM ThuongPhat tp WHERE tp.MaNV = nv.MaNV AND tp.Thangg = @Thang_BangLuong AND tp.Namm = @Nam_BangLuong), 0), dbo.fn_TongGioTangCa_Thang(nv.MaNV, @Thang_BangLuong, @Nam_BangLuong)
FROM NhanVien nv LEFT JOIN HopDong hd ON nv.MaNV = hd.MaNV AND (hd.NgayKetThuc IS NULL OR hd.NgayKetThuc >= CAST(CONCAT(@Nam_BangLuong, '-', @Thang_BangLuong, '-01') AS DATE)) LEFT JOIN LuongCoban lcb ON nv.MaCV = lcb.MaCV GROUP BY nv.MaNV, hd.LuongCoBan, lcb.MucLuong; END;
GO

CREATE PROCEDURE sp_XoaChamCongTheoThang @Thang_Input INT, @Nam_Input INT, @XacNhan NVARCHAR(10) = NULL
AS BEGIN IF @XacNhan <> 'XAC_NHAN' BEGIN RAISERROR(N'Vui lòng xác nhận', 16, 1); RETURN; END DELETE FROM BangChamCong WHERE MONTH(Ngay) = @Thang_Input AND YEAR(Ngay) = @Nam_Input; END;
GO
CREATE PROCEDURE sp_CapNhatGioTangCa @MaNV_Input INT, @Ngay_Input DATE, @GioTangCa_Moi DECIMAL(5,2)
AS BEGIN IF @GioTangCa_Moi < 0 OR @GioTangCa_Moi > 12 BEGIN RAISERROR(N'Giờ tăng ca không hợp lệ', 16, 1); RETURN; END UPDATE BangChamCong SET GioTangCa = @GioTangCa_Moi WHERE MaNV = @MaNV_Input AND Ngay = @Ngay_Input; END;
GO
CREATE PROCEDURE sp_ThongKeLuongTheoThang @Thang_Input INT, @Nam_Input INT
AS BEGIN SELECT bl.MaNV, nv.HoTen, bl.LuongCoBan, bl.TongPhuCap, bl.TongThuongPhat, bl.TongGioTangCa, bl.LuongThucNhan FROM BangLuong bl INNER JOIN NhanVien nv ON bl.MaNV = nv.MaNV WHERE bl.Thang = @Thang_Input AND bl.Nam = @Nam_Input ORDER BY bl.LuongThucNhan DESC; END;
GO
CREATE PROCEDURE sp_XuatBaoCaoLuong @MaNV_Input INT = NULL, @Thang_Input INT, @Nam_Input INT
AS BEGIN SELECT * FROM BangLuong WHERE Thang = @Thang_Input AND Nam = @Nam_Input AND (@MaNV_Input IS NULL OR MaNV = @MaNV_Input); END;
GO

-- [TÂM] Quản lý thưởng phạt (Upsert)
CREATE PROCEDURE sp_ThemThuongPhat_AndCapNhatBangLuong @MaNV INT, @Loai NVARCHAR(20), @SoTien DECIMAL(18,2), @LyDo NVARCHAR(200) = NULL, @Thangg INT, @Namm INT
AS BEGIN SET NOCOUNT ON; BEGIN TRY BEGIN TRAN;
IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV) RAISERROR(N'Nhân viên không tồn tại.', 16, 1);
INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo) VALUES (@MaNV, @Thangg, @Namm, @Loai, @SoTien, @LyDo);
IF NOT EXISTS (SELECT 1 FROM BangLuong WHERE MaNV = @MaNV AND Thang = @Thangg AND Nam = @Namm)
BEGIN DECLARE @LuongCoBan DECIMAL(18,2) = dbo.fn_LayLuongCoBan_NV(@MaNV); INSERT INTO BangLuong (MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa) VALUES (@MaNV, @Thangg, @Namm, @LuongCoBan, 0, 0, 0); END
UPDATE BangLuong SET TongThuongPhat = dbo.fn_TongThuongPhat_NV_Thang(@MaNV, @Thangg, @Namm) WHERE MaNV = @MaNV AND Thang = @Thangg AND Nam = @Namm;
COMMIT TRAN; END TRY BEGIN CATCH IF XACT_STATE() <> 0 ROLLBACK TRAN; THROW; END CATCH END;
GO

-- PHẦN 5: TRIGGER (Đã xóa trùng lặp và lỗi logic)
-- ======================================================================================

-- [PHÚC]
CREATE TRIGGER tr_HopDong_AfterUpdate 
ON HopDong
AFTER UPDATE 
AS 
	BEGIN 
		UPDATE NhanVien 
			SET TrangThai = N'Nghỉ việc' 
			WHERE MaNV IN (
			SELECT i.MaNV 
			FROM inserted i 
			WHERE i.NgayKetThuc < GETDATE()); 
	END;
GO
CREATE TRIGGER tr_HopDong_AlterInsert 
ON HopDong 
AFTER INSERT 
AS
	BEGIN 
		UPDATE NhanVien 
			SET TrangThai = N'Đang làm'
			WHERE MaNV IN (
			SELECT i.MaNV 
			FROM inserted i
			WHERE i.NgayKetThuc IS NULL OR i.NgayKetThuc > GETDATE());
	END;
GO

CREATE TRIGGER tr_NhanVien_AfterUpdate 
ON NhanVien 
AFTER UPDATE 
AS 
	BEGIN 
		UPDATE nv 
			SET nv.LuongHienTai = lc.MucLuong 
			FROM NhanVien nv 
			JOIN inserted i ON nv.MaNV = i.MaNV 
			JOIN LuongCoban lc  ON i.MaCV = lc.MaCV 
			WHERE i.MaCV <> (
				SELECT d.MaCV FROM deleted d 
				WHERE d.MaNV = i.MaNV); 
	END;
GO

CREATE TRIGGER tr_LuongCoBan_AfterUpdate 
ON LuongCoBan 
AFTER UPDATE 
AS 
	BEGIN 
		INSERT INTO LuongCoBanLog(MaCV, MucLuongCu, MucLuongMoi) 
		SELECT d.MaCV, d.MucLuong, i.MucLuong
		FROM inserted i 
		JOIN deleted d ON i.MaCV = d.MaCV 
		WHERE i.MucLuong <> d.MucLuong;
	END;
GO


--  Trigger chặn lương âm
-- Bảo vệ: Không bao giờ được nhập lương < 0 vào Hợp đồng
CREATE TRIGGER trg_CheckLuongHopDong ON HopDong AFTER INSERT, UPDATE AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE LuongCoBan < 0)
    BEGIN
        RAISERROR(N'Lương cơ bản không được âm!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

--  Trigger bảo vệ tài khoản Admin
-- Bảo vệ: Không cho phép xóa tài khoản có quyền Admin
CREATE TRIGGER trg_BaoVeAdmin 
ON TaiKhoan 
FOR DELETE 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE Quyen = 'Admin')
    BEGIN
        RAISERROR(N'Không thể xóa tài khoản Quản trị viên!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

--  Trigger kiểm tra tuổi lao động
-- Bảo vệ: Nhân viên phải đủ 18 tuổi
CREATE TRIGGER trg_CheckTuoiLaoDong 
ON NhanVien 
AFTER INSERT, UPDATE 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DATEDIFF(YEAR, NgaySinh, GETDATE()) < 18)
    BEGIN
        RAISERROR(N'Nhân viên chưa đủ 18 tuổi!', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO


-- Trigger chặn xóa phòng ban nếu còn nhân viên
-- Bảo vệ: Ràng buộc toàn vẹn dữ liệu
CREATE TRIGGER trg_ChanXoaPhongBanCoNguoi 
ON PhongBan 
INSTEAD OF DELETE 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NhanVien WHERE MaPB IN (SELECT MaPB FROM deleted))
    BEGIN
        RAISERROR(N'Phòng ban này đang có nhân viên, không thể xóa! Hãy chuyển nhân viên đi trước.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM PhongBan WHERE MaPB IN (SELECT MaPB FROM deleted);
    END
END;
GO
--======================================================================================
-- [TRƯỜNG]
CREATE TRIGGER trg_Log_Delete_NhanVien ON NhanVien AFTER DELETE AS BEGIN INSERT INTO LichSuXoaNhanVien(MaNV, HoTen, NgayXoa, LyDo) SELECT d.MaNV, d.HoTen, GETDATE(), N'Xóa nhân viên' FROM deleted d; END;
GO
CREATE TRIGGER trg_Log_TaoTaiKhoan ON TaiKhoan AFTER INSERT AS BEGIN INSERT INTO LichSuTaiKhoan(MaNV, TenDangNhap, NgayTao) SELECT MaNV, TenDangNhap, GETDATE() FROM inserted; END;
GO
CREATE TRIGGER trg_SetNull_MaPB_WhenPhongBanXoa ON PhongBan AFTER DELETE AS BEGIN UPDATE NhanVien SET MaPB = NULL WHERE MaPB IN (SELECT MaPB FROM deleted); END;
GO
CREATE TRIGGER trg_CapNhatLuongKhiDoiHeSo ON ChucVu AFTER UPDATE AS BEGIN UPDATE nv SET nv.LuongHienTai = i.HeSoLuong * 1000000 FROM NhanVien nv INNER JOIN inserted i ON nv.MaCV = i.MaCV; END;
GO

-- [TUẤN] (Duy nhất 1 trigger chặn trùng chấm công)
CREATE TRIGGER trg_PreventDuplicate_ChanCong ON BangChamCong AFTER INSERT AS BEGIN IF EXISTS (SELECT 1 FROM BangChamCong c JOIN inserted i ON c.MaNV = i.MaNV AND c.Ngay = i.Ngay GROUP BY c.MaNV, c.Ngay HAVING COUNT(*) > 1) BEGIN RAISERROR(N'Chấm công trùng ngày!', 16, 1); ROLLBACK TRANSACTION; END END;
GO
CREATE TRIGGER trg_ValidateGioTangCa ON BangChamCong AFTER INSERT, UPDATE AS BEGIN IF EXISTS (SELECT 1 FROM inserted WHERE GioTangCa < 0 OR GioTangCa > 12) BEGIN RAISERROR(N'Giờ tăng ca không hợp lệ (0-12 giờ)!', 16, 1); ROLLBACK TRANSACTION; END END;
GO
CREATE TRIGGER trg_ValidateNgayCong ON BangChamCong AFTER INSERT, UPDATE AS BEGIN IF EXISTS (SELECT 1 FROM inserted WHERE NgayCong NOT IN (0, 0.5, 1.0) OR NgayCong < 0) BEGIN RAISERROR(N'Ngày công không hợp lệ!', 16, 1); ROLLBACK TRANSACTION; END END;
GO
CREATE TRIGGER trg_AutoUpdateBangLuong ON BangChamCong AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE bl SET bl.TongGioTangCa = (SELECT ISNULL(SUM(cc.GioTangCa), 0) FROM BangChamCong cc WHERE cc.MaNV = bl.MaNV AND MONTH(cc.Ngay) = bl.Thang AND YEAR(cc.Ngay) = bl.Nam) FROM BangLuong bl JOIN inserted i ON bl.MaNV = i.MaNV WHERE bl.Thang = MONTH(i.Ngay) AND bl.Nam = YEAR(i.Ngay); END;
GO
CREATE TRIGGER trg_LogChamCongChanges ON BangChamCong AFTER INSERT, UPDATE, DELETE AS BEGIN 
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) INSERT INTO Log_ChamCong (HanhDong, MaNV, Ngay, NgayCong_Moi, GioTangCa_Moi) SELECT 'INSERT', i.MaNV, i.Ngay, i.NgayCong, i.GioTangCa FROM inserted i;
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted) INSERT INTO Log_ChamCong (HanhDong, MaNV, Ngay, NgayCong_Cu, NgayCong_Moi, GioTangCa_Cu, GioTangCa_Moi) SELECT 'UPDATE', i.MaNV, i.Ngay, d.NgayCong, i.NgayCong, d.GioTangCa, i.GioTangCa FROM inserted i JOIN deleted d ON i.MaNV = d.MaNV AND i.Ngay = d.Ngay;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted) INSERT INTO Log_ChamCong (HanhDong, MaNV, Ngay, NgayCong_Cu, GioTangCa_Cu) SELECT 'DELETE', d.MaNV, d.Ngay, d.NgayCong, d.GioTangCa FROM deleted d;
END;
GO

-- [TÂM] (Trigger update lương khi thưởng/phạt thay đổi)
CREATE TRIGGER trg_AfterInsert_ThuongPhat ON ThuongPhat AFTER INSERT AS BEGIN 
    UPDATE bl SET bl.TongThuongPhat = bl.TongThuongPhat + ISNULL(tp.TongCong,0) FROM BangLuong bl 
    INNER JOIN (SELECT i.MaNV, i.Thangg, i.Namm, SUM(CASE WHEN i.Loai = N'Thưởng' THEN i.SoTien WHEN i.Loai = N'Phạt' THEN -i.SoTien ELSE 0 END) AS TongCong FROM inserted i GROUP BY i.MaNV, i.Thangg, i.Namm) tp 
    ON bl.MaNV = tp.MaNV AND bl.Thang = tp.Thangg AND bl.Nam = tp.Namm;
END;
GO
-- ==================================================================================
-- CURSOR (Con Trỏ ) (Phúc)
-- 2. Cursor tính thưởng KPI cuối năm
-- Logic: Duyệt từng nhân viên, đếm số lần đi muộn (Phạt) trong năm để xếp loại
CREATE OR ALTER PROCEDURE sp_Cursor_XepLoaiThiDua_View
    @Nam INT
AS
BEGIN
    -- Tạo bảng tạm để chứa kết quả
    DECLARE @KetQua TABLE (
        MaNV INT,
        HoTen NVARCHAR(40),
        LuongHienTai DECIMAL(18,2),
        SoLanPhat INT,
        XepLoai NVARCHAR(50),
        ThuongTet DECIMAL(18,2)
    );

    DECLARE @MaNV INT, @HoTen NVARCHAR(40), @Luong DECIMAL(18,2), @SoLanPhat INT;
    
    DECLARE cur_ThiDua CURSOR FOR 
    SELECT MaNV, HoTen, LuongHienTai FROM NhanVien WHERE TrangThai = N'Đang làm';
    
    OPEN cur_ThiDua;
    FETCH NEXT FROM cur_ThiDua INTO @MaNV, @HoTen, @Luong;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @SoLanPhat = COUNT(*) FROM ThuongPhat WHERE MaNV = @MaNV AND Namm = @Nam AND Loai = N'Phạt';
        
        DECLARE @XepLoai NVARCHAR(50);
        DECLARE @TienThuong DECIMAL(18,2);

        IF @SoLanPhat = 0 
        BEGIN
            SET @XepLoai = N'Xuất sắc (A)';
            SET @TienThuong = @Luong * 2.0; -- Thưởng 2 tháng lương
        END
        ELSE IF @SoLanPhat < 3 
        BEGIN
            SET @XepLoai = N'Khá (B)';
            SET @TienThuong = @Luong * 1.0; -- Thưởng 1 tháng lương
        END
        ELSE 
        BEGIN
            SET @XepLoai = N'Trung bình (C)';
            SET @TienThuong = 0; -- Không thưởng
        END

        INSERT INTO @KetQua VALUES (@MaNV, @HoTen, @Luong, @SoLanPhat, @XepLoai, @TienThuong);

        FETCH NEXT FROM cur_ThiDua INTO @MaNV, @HoTen, @Luong;
    END
    
    CLOSE cur_ThiDua;
    DEALLOCATE cur_ThiDua;

    SELECT * FROM @KetQua ORDER BY ThuongTet DESC;
END;
GO

-- 2. PROC CHỐT THƯỞNG: Lưu thật vào bảng ThuongPhat
CREATE OR ALTER PROCEDURE sp_Cursor_ChotThuongTet
    @Nam INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM ThuongPhat WHERE Namm = @Nam AND LyDo LIKE N'Thưởng Tết%')
    BEGIN
        RAISERROR(N'Năm này đã chốt thưởng Tết rồi! Vui lòng kiểm tra lại.', 16, 1);
        RETURN;
    END

    DECLARE @MaNV INT, @Luong DECIMAL(18,2), @SoLanPhat INT;
    DECLARE cur_ChotThuong CURSOR FOR SELECT MaNV, LuongHienTai FROM NhanVien WHERE TrangThai = N'Đang làm';

    OPEN cur_ChotThuong;
    FETCH NEXT FROM cur_ChotThuong INTO @MaNV, @Luong;

    BEGIN TRAN;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @SoLanPhat = COUNT(*) FROM ThuongPhat WHERE MaNV = @MaNV AND Namm = @Nam AND Loai = N'Phạt';
        
        DECLARE @TienThuong DECIMAL(18,2) = 0;
        DECLARE @XepLoai NVARCHAR(20) = '';

        IF @SoLanPhat = 0 SET @TienThuong = @Luong * 2.0; 
        ELSE IF @SoLanPhat < 3 SET @TienThuong = @Luong * 1.0;
        
        IF @TienThuong > 0
        BEGIN
            INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo)
            VALUES (@MaNV, 12, @Nam, N'Thưởng', @TienThuong, N'Thưởng Tết ' + CAST(@Nam AS NVARCHAR));
        END

        FETCH NEXT FROM cur_ChotThuong INTO @MaNV, @Luong;
    END
    COMMIT TRAN;

    CLOSE cur_ChotThuong;
    DEALLOCATE cur_ChotThuong;
    
    PRINT N'Đã chốt thưởng thành công!';
END;
GO
--(Phúc)
-- ======================================================================================
DECLARE @i INT = 1;
DECLARE @TargetCount INT = 300; -- Số lượng nhân viên
DECLARE @HoTen NVARCHAR(40), @Ho NVARCHAR(10), @Dem NVARCHAR(10), @Ten NVARCHAR(10);
DECLARE @GioiTinh NVARCHAR(5), @NgaySinh DATE, @DiaChi NVARCHAR(50), @DienThoai NVARCHAR(15), @Email NVARCHAR(60);
DECLARE @MaPB INT, @MaCV INT, @NewMaNV INT;
DECLARE @ListHo TABLE (Val NVARCHAR(10)); INSERT INTO @ListHo VALUES (N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Huỳnh');
DECLARE @ListTen TABLE (Val NVARCHAR(10)); INSERT INTO @ListTen VALUES (N'An'), (N'Bình'), (N'Cường'), (N'Tuấn'), (N'Tâm'), (N'Phúc'), (N'Trường');
DECLARE @ListPhuCap TABLE (Loai NVARCHAR(50), Tien DECIMAL(18,2)); INSERT INTO @ListPhuCap VALUES (N'Xăng xe', 500000), (N'Điện thoại', 300000);

SET NOCOUNT ON;
WHILE @i <= @TargetCount
BEGIN
    BEGIN TRY
        SELECT TOP 1 @Ho = Val FROM @ListHo ORDER BY NEWID();
        SELECT TOP 1 @Ten = Val FROM @ListTen ORDER BY NEWID();
        SET @HoTen = @Ho + ' Văn ' + @Ten;
        SET @GioiTinh = N'Nam'; SET @NgaySinh = DATEADD(YEAR, -20, GETDATE()); SET @DiaChi = N'HCM';
        SET @Email = LOWER(@Ten + CAST(@i AS VARCHAR)) + '@company.vn';
        SET @MaPB = (ABS(CHECKSUM(NEWID())) % 6) + 1;
        SET @MaCV = (ABS(CHECKSUM(NEWID())) % 5) + 1;
        SET @DienThoai = '0900000' + CAST(@i AS VARCHAR);

        INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV) VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV);
        SET @NewMaNV = SCOPE_IDENTITY();

        EXEC sp_ThemHopDong @MaNV = @NewMaNV, @NgayBatDau = '2023-01-01', @LoaiHD = N'Không thời hạn', @Luongcoban = 10000000;
        EXEC sp_TaoTaiKhoan @TenDangNhap = @Email, @MatKhau = '123456', @MaNV = @NewMaNV;
        
        IF @i % 2 = 0 EXEC sp_ThemPhuCap @MaNV = @NewMaNV, @LoaiPhuCap = N'Xăng xe', @SoTien = 500000;

        SET @i = @i + 1;
    END TRY
    BEGIN CATCH SET @i = @i + 1; END CATCH
END;
GO

-- ======================================================================================
-- PHẦN 7: BẢO MẬT & PHÂN QUYỀN (Phúc)
-- ======================================================================================
USE QL_LuongNV;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_role_NhanSu' AND type = 'R')
BEGIN
    CREATE ROLE db_role_NhanSu;
    PRINT 'Role db_role_NhanSu created.';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_role_KeToan' AND type = 'R')
BEGIN
    CREATE ROLE db_role_KeToan;
    PRINT 'Role db_role_KeToan created.';
END
GO

-- HR
GRANT SELECT, INSERT, UPDATE, DELETE ON NhanVien TO db_role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON PhongBan TO db_role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON ChucVu TO db_role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON HopDong TO db_role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON BangChamCong TO db_role_NhanSu;
GRANT SELECT ON TaiKhoan TO db_role_NhanSu; 
GRANT SELECT ON Roles TO db_role_NhanSu;

GRANT EXECUTE ON sp_AddNhanVien TO db_role_NhanSu;
GRANT EXECUTE ON sp_ThemHopDong TO db_role_NhanSu;
GRANT EXECUTE ON sp_QuanLyPhongBan TO db_role_NhanSu;
GRANT EXECUTE ON sp_QuanLyChucVu TO db_role_NhanSu;
GRANT EXECUTE ON sp_DanhSachHopDongNV TO db_role_NhanSu;
GRANT EXECUTE ON sp_TaoTaiKhoan TO db_role_NhanSu;      
GRANT EXECUTE ON fn_DemNhanVienTrongPhong TO db_role_NhanSu;
GRANT EXECUTE ON fn_LayMaNhanVienTheoEmail TO db_role_NhanSu;
GRANT EXECUTE ON fn_KiemTraNhanVienTonTai TO db_role_NhanSu;
GRANT EXECUTE ON fn_LayQuyenTaiKhoan TO db_role_NhanSu;
GRANT EXECUTE ON fn_HopDongConHieuLuc TO db_role_NhanSu;
GRANT EXECUTE ON fn_SoLuongHopDongHetHan TO db_role_NhanSu;
GRANT EXECUTE ON fn_TinhThamNien TO db_role_NhanSu;
GRANT EXECUTE ON fn_KiemTraChuyenCan TO db_role_NhanSu;
GRANT EXECUTE ON fn_TinhTongNgayCong TO db_role_NhanSu;
GRANT EXECUTE ON fn_TinhTyLeDiLam TO db_role_NhanSu;
GRANT EXECUTE ON sp_CapNhatTrangThaiNV TO db_role_NhanSu; 
GRANT EXECUTE ON sp_XoaChamCongTheoThang TO db_role_NhanSu;
GRANT EXECUTE ON sp_CapNhatGioTangCa TO db_role_NhanSu;

-- KẾ TOÁN 
GRANT SELECT, INSERT, UPDATE, DELETE ON BangLuong TO db_role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON PhuCap TO db_role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON ThuongPhat TO db_role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON LuongCoBan TO db_role_KeToan;
GRANT SELECT ON NhanVien TO db_role_KeToan;
GRANT SELECT ON HopDong TO db_role_KeToan;
GRANT SELECT ON BangChamCong TO db_role_KeToan; 

GRANT EXECUTE ON sp_TinhBangLuong_Thang TO db_role_KeToan;
GRANT EXECUTE ON sp_ThemPhuCap TO db_role_KeToan;
GRANT EXECUTE ON sp_QuanLyLuongCoBan TO db_role_KeToan;
GRANT EXECUTE ON sp_TongPhuCapTheoLoai TO db_role_KeToan;
GRANT EXECUTE ON sp_ThemThuongPhat_AndCapNhatBangLuong TO db_role_KeToan; 
GRANT EXECUTE ON sp_ThongKeLuongTheoThang TO db_role_KeToan;
GRANT EXECUTE ON sp_XuatBaoCaoLuong TO db_role_KeToan;
GRANT EXECUTE ON sp_TangLuongHangLoat TO db_role_KeToan;

GRANT EXECUTE ON fn_TongPhuCap_NV TO db_role_KeToan;
GRANT EXECUTE ON fn_TongThuongPhat_NV_LichSu TO db_role_KeToan;
GRANT EXECUTE ON fn_TongPhuCapLoai TO db_role_KeToan;
GRANT EXECUTE ON fn_TrungBinhHeSoLuong TO db_role_KeToan;
GRANT EXECUTE ON fn_TongGioTangCa_Thang TO db_role_KeToan;
GRANT EXECUTE ON fn_LayLuongCoBan_NV TO db_role_KeToan;
GRANT EXECUTE ON fn_TinhLuongThucNhan_Tam TO db_role_KeToan;
GRANT EXECUTE ON fn_TongThuongPhat_NV_Thang TO db_role_KeToan;
GO

USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NhanSuLogin') 
    DROP LOGIN NhanSuLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'KeToanLogin') 
    DROP LOGIN KeToanLogin;

CREATE LOGIN NhanSuLogin WITH PASSWORD = N'NhanSu@123', DEFAULT_DATABASE = QL_LuongNV, CHECK_POLICY = OFF;
CREATE LOGIN KeToanLogin WITH PASSWORD = N'KeToan@123', DEFAULT_DATABASE = QL_LuongNV, CHECK_POLICY = OFF;
GO

USE QL_LuongNV;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'NhanSuUser') 
    DROP USER NhanSuUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'KeToanUser') 
    DROP USER KeToanUser;

CREATE USER NhanSuUser FOR LOGIN NhanSuLogin;
CREATE USER KeToanUser FOR LOGIN KeToanLogin;

ALTER ROLE db_role_NhanSu ADD MEMBER NhanSuUser;
ALTER ROLE db_role_KeToan ADD MEMBER KeToanUser;
GO




-- ===================================================
-- Backup -- (Trường)
-- ===================================================
-- BƯỚC 1: Phục hồi file backup FULL gần nhất
-- Sử dụng WITH NORECOVERY để database ở trạng thái chờ (Restoring),
-- chưa cho phép truy vấn để có thể nạp tiếp các bản backup sau.
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_FULL.bak'
WITH NORECOVERY;

-- BƯỚC 2: Phục hồi bản DIFFERENTIAl backup gần nhất
-- Sử dụng WITH RECOVERY (mặc định) để báo hiệu quá trình phục hồi hoàn tất,
-- database chuyển sang trạng thái Online và sẵn sàng hoạt động.
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_DIFF.bak'
WITH RECOVERY;

USE master;
GO

-- =============================================================
-- BƯỚC 1: Backup "The tail of the log" (Backup phần đuôi Log)
-- =============================================================
-- Bước quan trọng nhất để cứu dữ liệu từ 12h trưa T6 đến 16h chiều T6.
-- NO_TRUNCATE đảm bảo backup được ngay cả khi database bị hỏng file data.
BACKUP LOG QLTV
TO DISK = 'C:\QLTV_LOG_TAIL.trn'
WITH NO_TRUNCATE, INIT;
GO

-- =============================================================
-- BƯỚC 2: Phục hồi bản FULL BACKUP (23h tối Thứ 4)
-- =============================================================
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_FULL.bak'
WITH NORECOVERY; -- Database ở trạng thái Restoring

-- =============================================================
-- BƯỚC 3: Phục hồi bản DIFFERENTIAL BACKUP (23h tối Thứ 5)
-- =============================================================
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_DIFF.bak'
WITH NORECOVERY; -- Vẫn giữ trạng thái Restoring

-- =============================================================
-- BƯỚC 4: Phục hồi bản LOG BACKUP (12h trưa Thứ 6)
-- =============================================================
RESTORE LOG QLTV
FROM DISK = 'C:\QLTV_LOG.trn'
WITH NORECOVERY; -- Vẫn giữ trạng thái Restoring

-- =============================================================
-- BƯỚC 5: Phục hồi bản LOG BACKUP CÁI ĐUÔI (Vừa tạo ở Bước 1)
-- =============================================================
-- Đây là bước cuối cùng, dùng WITH RECOVERY để database Online.
-- Nếu muốn dừng đúng 16h, dùng thêm STOPAT (tùy chọn).

RESTORE LOG QLTV
FROM DISK = 'C:\QLTV_LOG_TAIL.trn'
WITH RECOVERY; 
-- Hoặc nếu muốn chính xác tuyệt đối thời gian:
-- WITH RECOVERY, STOPAT = '2025-12-05 16:00:00'; (Giả sử ngày T6 là 05/12)
GO

-- BƯỚC 1: Phục hồi file backup FULL gần nhất
-- Sử dụng WITH NORECOVERY để database ở trạng thái chờ (Restoring),
-- chưa cho phép truy vấn để có thể nạp tiếp các bản backup sau.
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_FULL.bak'
WITH NORECOVERY;

-- BƯỚC 2: Phục hồi bản DIFFERENTIAl backup gần nhất
-- Sử dụng WITH RECOVERY (mặc định) để báo hiệu quá trình phục hồi hoàn tất,
-- database chuyển sang trạng thái Online và sẵn sàng hoạt động.
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_DIFF.bak'
WITH RECOVERY;

USE master;
GO

-- =============================================================
-- BƯỚC 1: Backup "The tail of the log" (Backup phần đuôi Log)
-- =============================================================
-- Bước quan trọng nhất để cứu dữ liệu từ 12h trưa T6 đến 16h chiều T6.
-- NO_TRUNCATE đảm bảo backup được ngay cả khi database bị hỏng file data.
BACKUP LOG QLTV
TO DISK = 'C:\QLTV_LOG_TAIL.trn'
WITH NO_TRUNCATE, INIT;
GO

-- =============================================================
-- BƯỚC 2: Phục hồi bản FULL BACKUP (23h tối Thứ 4)
-- =============================================================
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_FULL.bak'
WITH NORECOVERY; -- Database ở trạng thái Restoring

-- =============================================================
-- BƯỚC 3: Phục hồi bản DIFFERENTIAL BACKUP (23h tối Thứ 5)
-- =============================================================
RESTORE DATABASE QLTV
FROM DISK = 'C:\QLTV_DIFF.bak'
WITH NORECOVERY; -- Vẫn giữ trạng thái Restoring

-- =============================================================
-- BƯỚC 4: Phục hồi bản LOG BACKUP (12h trưa Thứ 6)
-- =============================================================
RESTORE LOG QLTV
FROM DISK = 'C:\QLTV_LOG.trn'
WITH NORECOVERY; -- Vẫn giữ trạng thái Restoring

-- =============================================================
-- BƯỚC 5: Phục hồi bản LOG BACKUP CÁI ĐUÔI (Vừa tạo ở Bước 1)
-- =============================================================
-- Đây là bước cuối cùng, dùng WITH RECOVERY để database Online.
-- Nếu muốn dừng đúng 16h, dùng thêm STOPAT (tùy chọn).

RESTORE LOG QLTV
FROM DISK = 'C:\QLTV_LOG_TAIL.trn'
WITH RECOVERY; 
-- Hoặc nếu muốn chính xác tuyệt đối thời gian:
-- WITH RECOVERY, STOPAT = '2025-12-05 16:00:00'; (Giả sử ngày T6 là 05/12)
5 hours ago

Phuc: Done DB
GO














-- +++++++++++++++++++++++++++ Tạo dữ liệu ảo( Test _ Phúc) ++++++++++++++++++++ ----
SELECT * FROM TaiKhoan
SELECT * FROM PhongBan
SELECT * FROM ChucVu
SELECT * FROM Roles

USE QL_LuongNV;
GO

SET NOCOUNT ON; -- Tắt thông báo dòng để chạy nhanh hơn

-- 1. Gán ngẫu nhiên Phòng Ban & Chức Vụ cho ai đang thiếu
UPDATE NhanVien
SET MaPB = (ABS(CHECKSUM(NEWID())) % 6) + 1, 
    MaCV = (ABS(CHECKSUM(NEWID())) % 5) + 1  -- Random CV từ 1-5 (Nhân viên -> Kế toán trưởng)
WHERE MaPB IS NULL OR MaCV IS NULL;

-- 2. Đảm bảo có đủ các vị trí quan trọng (Để phân quyền)
-- Set 1 người làm Admin (Giám đốc)
UPDATE TOP(1) NhanVien SET MaCV = 3, MaPB = 1 WHERE MaNV = 1; 
-- Set 1 người làm Kế toán
UPDATE TOP(1) NhanVien SET MaCV = 5, MaPB = 2 WHERE MaNV = 2; 
-- Set 1 người làm Nhân sự
UPDATE TOP(1) NhanVien SET MaCV = 2, MaPB = 1 WHERE MaNV = 3; 

-- 3. Cập nhật Lương hiện tại (Logic của bạn - Rất chuẩn)
-- Ưu tiên Hợp đồng -> Chức vụ -> Mặc định
UPDATE NhanVien
SET LuongHienTai = (
    SELECT TOP 1 LuongCoBan FROM HopDong WHERE HopDong.MaNV = NhanVien.MaNV ORDER BY NgayBatDau DESC
);

UPDATE NhanVien
SET LuongHienTai = (
    SELECT TOP 1 MucLuong FROM LuongCoBan WHERE LuongCoBan.MaCV = NhanVien.MaCV
)
WHERE LuongHienTai IS NULL OR LuongHienTai = 0;

-- 4. Reset và Tạo lại Phụ cấp (Sinh động hơn)
DELETE FROM PhuCap;
INSERT INTO PhuCap (MaNV, LoaiPhuCap, SoTien)
SELECT MaNV, N'Xăng xe', 500000 FROM NhanVien; -- Ai cũng có xăng xe

INSERT INTO PhuCap (MaNV, LoaiPhuCap, SoTien)
SELECT TOP 50 PERCENT MaNV, N'Ăn trưa', 730000 FROM NhanVien ORDER BY NEWID(); -- 50% có ăn trưa

INSERT INTO PhuCap (MaNV, LoaiPhuCap, SoTien)
SELECT MaNV, N'Trách nhiệm', 2000000 FROM NhanVien WHERE MaCV IN (2, 3, 5); -- Chỉ sếp có trách nhiệm



DELETE FROM TaiKhoan;

INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, Quyen, MaRole)
SELECT 
    LEFT(Email, CHARINDEX('@', Email) - 1), -- User là phần trước @
    '123456', 
    MaNV,
    CASE 
        WHEN MaCV = 3 THEN 'Admin'   -- Giám đốc -> Admin
        WHEN MaPB = 2 THEN 'KeToan'  -- Phòng Kế toán -> Kế toán
        WHEN MaPB = 1 THEN 'NhanSu'  -- Phòng Nhân sự -> Nhân sự
        ELSE 'User'                  -- Còn lại -> User
    END,
    CASE 
        WHEN MaCV = 3 THEN 1
        WHEN MaPB = 1 THEN 2
        WHEN MaPB = 2 THEN 3
        ELSE 4
    END
FROM NhanVien
WHERE Email IS NOT NULL AND Email <> '';



-- Xóa sạch dữ liệu chấm công và lương cũ để tránh trùng
DELETE FROM ThuongPhat;
DELETE FROM BangLuong;
DELETE FROM BangChamCong;

-- Khai báo biến thời gian
DECLARE @StartYear INT = YEAR(DATEADD(YEAR, -1, GETDATE())); -- Năm ngoái
DECLARE @StartMonth INT = MONTH(DATEADD(YEAR, -1, GETDATE())); -- Tháng này năm ngoái
DECLARE @EndMonth INT = MONTH(GETDATE());
DECLARE @EndYear INT = YEAR(GETDATE());

-- Biến chạy
DECLARE @CurrMonth INT = @StartMonth;
DECLARE @CurrYear INT = @StartYear;

-- VÒNG LẶP QUA TỪNG THÁNG (Từ quá khứ -> Hiện tại)
WHILE (@CurrYear < @EndYear) OR (@CurrYear = @EndYear AND @CurrMonth <= @EndMonth)
BEGIN
    PRINT N'   --> Đang xử lý dữ liệu Tháng ' + CAST(@CurrMonth AS NVARCHAR) + '/' + CAST(@CurrYear AS NVARCHAR);

    -- A. SINH CHẤM CÔNG (Giả lập 24 ngày công/tháng)
    -- Để chạy nhanh, ta insert theo lô (Batch Insert) thay vì từng dòng
    -- Logic: Mỗi nhân viên làm việc từ ngày 1 -> 24 của tháng
    DECLARE @Day INT = 1;
    WHILE @Day <= 24
    BEGIN
        DECLARE @WorkDate DATE = DATEFROMPARTS(@CurrYear, @CurrMonth, @Day);
        
        -- Chỉ insert ngày trong tuần (Bỏ qua T7, CN nếu muốn, ở đây làm đơn giản là insert hết)
        INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
        SELECT 
            MaNV, 
            @WorkDate, 
            1.0, -- Đủ công
            CASE 
                WHEN (ABS(CHECKSUM(NEWID())) % 10) < 2 THEN 2.0 -- 20% cơ hội tăng ca 2 tiếng
                ELSE 0 
            END
        FROM NhanVien;

        SET @Day = @Day + 1;
    END

    -- B. SINH THƯỞNG PHẠT (Ngẫu nhiên vài người/tháng)
    INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo)
    SELECT TOP 5 MaNV, @CurrMonth, @CurrYear, N'Thưởng', 500000, N'Thưởng KPI tháng ' + CAST(@CurrMonth AS NVARCHAR)
    FROM NhanVien ORDER BY NEWID();

    INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo)
    SELECT TOP 2 MaNV, @CurrMonth, @CurrYear, N'Phạt', 200000, N'Đi muộn tháng ' + CAST(@CurrMonth AS NVARCHAR)
    FROM NhanVien ORDER BY NEWID();

    -- C. TÍNH LƯƠNG THÁNG ĐÓ (QUAN TRỌNG NHẤT)
    -- Gọi lại SP tính lương mà bạn đã có để chốt sổ tháng đó
    EXEC sp_TinhBangLuong_Thang @Thang_BangLuong = @CurrMonth, @Nam_BangLuong = @CurrYear;

    -- Tăng thời gian
    SET @CurrMonth = @CurrMonth + 1;
    IF @CurrMonth > 12 
    BEGIN
        SET @CurrMonth = 1;
        SET @CurrYear = @CurrYear + 1;
    END
END

DECLARE @CountCC INT = (SELECT COUNT(*) FROM BangChamCong);
DECLARE @CountLuong INT = (SELECT COUNT(*) FROM BangLuong);
PRINT N'- Tổng bản ghi chấm công: ' + CAST(@CountCC AS NVARCHAR) + N' (Khoảng 70-80k dòng)';
PRINT N'- Tổng phiếu lương đã tạo: ' + CAST(@CountLuong AS NVARCHAR) + N' (Mỗi NV có ~12 phiếu)';

PRINT N'=== GỢI Ý TÀI KHOẢN ĐĂNG NHẬP ===';
SELECT TOP 3 TenDangNhap, '123456' as MatKhau, Quyen, 'Dùng để test Dashboard Admin' as GhiChu 
FROM TaiKhoan WHERE Quyen = 'Admin';

SELECT TOP 3 TenDangNhap, '123456' as MatKhau, Quyen, 'Dùng để test Portal Nhân viên' as GhiChu 
FROM TaiKhoan WHERE Quyen = 'User';
GO

-- 1. ADMIN (Quản trị viên)
SELECT TOP 3 TenDangNhap, N'123456' AS MatKhau, Quyen, N'Toàn quyền hệ thống' AS GhiChu 
FROM TaiKhoan WHERE Quyen = 'Admin';

-- 2. NHÂN SỰ (HR)
SELECT TOP 3 TenDangNhap, N'123456' AS MatKhau, Quyen, N'Quản lý hồ sơ, Hợp đồng, Chấm công' AS GhiChu 
FROM TaiKhoan WHERE Quyen = 'NhanSu';

-- 3. KẾ TOÁN (Accountant)
SELECT TOP 3 TenDangNhap, N'123456' AS MatKhau, Quyen, N'Tính lương, Thưởng phạt, Báo cáo' AS GhiChu 
FROM TaiKhoan WHERE Quyen = 'KeToan';

-- 4. USER (Nhân viên bình thường)
SELECT TOP 3 TenDangNhap, N'123456' AS MatKhau, Quyen, N'Chỉ xem cá nhân & Check-in' AS GhiChu 
FROM TaiKhoan WHERE Quyen = 'User';


UPDATE TaiKhoan 
SET MatKhau = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';