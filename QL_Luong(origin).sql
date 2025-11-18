
USE master;
GO

-- 1. KHỞI TẠO DATABASE
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QL_LuongNV')
BEGIN
    ALTER DATABASE QL_LuongNV SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QL_LuongNV;
END
GO

CREATE DATABASE QL_LuongNV;
GO

-- Ép buộc sử dụng Database vừa tạo
USE QL_LuongNV;
GO

-- ======================================================================================
-- PHẦN 2: TẠO CẤU TRÚC BẢNG (NỀN TẢNG CHUNG)
-- ======================================================================================

IF OBJECT_ID('dbo.PhongBan', 'U') IS NOT NULL DROP TABLE dbo.PhongBan;
CREATE TABLE PhongBan (
    MaPB int identity(1,1) not null primary key,
    TenPB nvarchar(50) not null Unique,
    NgayThanhLap Date Default GetDate()
);
GO

IF OBJECT_ID('dbo.ChucVu', 'U') IS NOT NULL DROP TABLE dbo.ChucVu;
CREATE TABLE ChucVu (
    MaCV int identity(1,1) not null primary key,
    TenCV nvarchar(50) not null unique,
    HeSoLuong Decimal(4,2) Check(HeSoLuong BETWEEN 1 AND 10)
);
GO

IF OBJECT_ID('dbo.NhanVien', 'U') IS NOT NULL DROP TABLE dbo.NhanVien;
CREATE TABLE NhanVien (
    MaNV int identity(1,1) not null primary key,
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
GO

IF OBJECT_ID('dbo.HopDong', 'U') IS NOT NULL DROP TABLE dbo.HopDong;
CREATE TABLE HopDong (
    MaHD int identity(1,1) not null primary key,
    MaNV int,
    NgayBatDau Date not null,
    NgayKetThuc Date,
    LoaiHD nvarchar(50) Check(LoaiHD in(N'Có thời hạn',N'Không thời hạn')),
    LuongCoBan decimal(18,2) check (LuongCoBan > 0),
    GhiChu nvarchar(200),
    CONSTRAINT FK_MaNV_HopDong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

IF OBJECT_ID('dbo.BangChamCong', 'U') IS NOT NULL DROP TABLE dbo.BangChamCong;
CREATE TABLE BangChamCong (
    MaCC int identity(1,1) not null primary key,
    MaNV int,
    Ngay Date not null,
    NgayCong decimal(4,2) default 1.0 check(NgayCong BETWEEN 0 AND 1),
    GioTangCa decimal(5,2) default 0 check (GioTangCa >= 0),
    CONSTRAINT FK_MaNV_BangChamCong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

IF OBJECT_ID('dbo.PhuCap', 'U') IS NOT NULL DROP TABLE dbo.PhuCap;
CREATE TABLE PhuCap (
    MaPC int identity(1,1) not null primary key,
    MaNV int,
    LoaiPhuCap nvarchar(50),
    SoTien decimal(18,2) check(SoTien>=0),
    CONSTRAINT FK_MaNV_PhuCap FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

IF OBJECT_ID('dbo.ThuongPhat', 'U') IS NOT NULL DROP TABLE dbo.ThuongPhat;
CREATE TABLE ThuongPhat (
    MaTP int identity(1,1) not null primary key,
    MaNV int,
    Loai nvarchar(20) check (Loai in(N'Thưởng',N'Phạt')),
    SoTien decimal(18,2) check(SoTien>0),
    LyDo nvarchar(200),
    CONSTRAINT FK_MaNV_ThuongPhat FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

IF OBJECT_ID('dbo.LuongCoBan', 'U') IS NOT NULL DROP TABLE dbo.LuongCoBan;
CREATE TABLE LuongCoBan (
    MaLCB int identity(1,1) not null primary key,
    MaCV int,
    MucLuong decimal(18,2) check (MucLuong>0),
    CONSTRAINT Fk_MaCV_LuongCoBan FOREIGN KEY (MaCV) REFERENCES ChucVu(MaCV)
);
GO

IF OBJECT_ID('dbo.BangLuong', 'U') IS NOT NULL DROP TABLE dbo.BangLuong;
CREATE TABLE BangLuong (
    MaBangLuong int identity(1,1) not null primary key,
    MaNV int,
    Thang int check(Thang BETWEEN 1 AND 12),
    Nam int check(Nam >= 2000),
    LuongCoBan decimal(18,2),
    TongPhuCap decimal(18,2),
    TongThuongPhat decimal(18,2),
    TongGioTangCa decimal(10,2),
    LuongThucNhan AS (LuongCoBan + ISNULL(TongPhuCap,0) + ISNULL(TongThuongPhat,0) + ISNULL(TongGioTangCa,0) * 50000),
    CONSTRAINT FK_MANV_BangLuong FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
CREATE TABLE Roles (
    MaRole INT IDENTITY(1,1) PRIMARY KEY,
    TenRole NVARCHAR(50) NOT NULL UNIQUE
);
GO

IF OBJECT_ID('dbo.TaiKhoan', 'U') IS NOT NULL DROP TABLE dbo.TaiKhoan;
CREATE TABLE TaiKhoan (
    TenDangNhap nvarchar(50) not null primary key,
    MatKhau nvarchar(100) not null,
    MaNV int,
    Quyen nvarchar(20) default N'User',
    MaRole INT, 
    CONSTRAINT FK_MaNV_TaiKhoan FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_TaiKhoan_Roles FOREIGN KEY (MaRole) REFERENCES Roles(MaRole)
);
GO

-- Các bảng Log (Chung)
IF OBJECT_ID('dbo.LichSuXoaNhanVien', 'U') IS NOT NULL DROP TABLE dbo.LichSuXoaNhanVien;
CREATE TABLE LichSuXoaNhanVien(ID INT IDENTITY(1,1) PRIMARY KEY, MaNV INT, HoTen NVARCHAR(40), NgayXoa DATETIME, LyDo NVARCHAR(200));

IF OBJECT_ID('dbo.LichSuTaiKhoan', 'U') IS NOT NULL DROP TABLE dbo.LichSuTaiKhoan;
CREATE TABLE LichSuTaiKhoan(ID INT IDENTITY(1,1) PRIMARY KEY, MaNV INT, TenDangNhap NVARCHAR(50), NgayTao DATETIME DEFAULT GETDATE());

IF OBJECT_ID('dbo.LuongCoBanLog', 'U') IS NOT NULL DROP TABLE dbo.LuongCoBanLog;
CREATE TABLE LuongCoBanLog(ID INT IDENTITY(1,1) PRIMARY KEY, MaCV INT, MucLuongCu DECIMAL(18,2), MucLuongMoi DECIMAL(18,2), NgayCapNhat DATETIME DEFAULT GETDATE());
GO

-- ==================== 3. DỮ LIỆU MẪU CƠ BẢN ====================
USE QL_LuongNV;
GO

INSERT INTO Roles (TenRole) VALUES (N'Admin'), (N'NhanSu'), (N'KeToan'), (N'NhanVien');
INSERT INTO PhongBan(TenPB) VALUES (N'Phòng Nhân Sự'), (N'Phòng Kế Toán'), (N'Phòng IT'), (N'Phòng Kinh Doanh'), (N'Phòng Marketing'), (N'Phòng Hành Chính');
INSERT INTO ChucVu(TenCV,HeSoLuong) VALUES (N'Nhân viên',1.20), (N'Trưởng phòng',2.00), (N'Giám đốc',3.50), (N'Phó phòng', 1.70), (N'Kế toán trưởng', 2.20);
INSERT INTO LuongCoBan(MaCV, MucLuong) VALUES (1, 8000000), (2, 12000000), (3, 20000000), (4, 10000000), (5, 13000000);
GO

-- ======================================================================================
-- PHẦN 4: HÀM (FUNCTIONS) - ĐÃ PHÂN CHIA
-- ======================================================================================

-- ---------------------------------------------------------------------------
-- [PHÚC] CÁC HÀM TÍNH TOÁN LƯƠNG & CHẾ ĐỘ
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.fn_TongPhuCap_NV', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TongPhuCap_NV;
GO
-- [PHÚC] [CHỨC NĂNG]: Tính tổng tiền phụ cấp của một nhân viên
CREATE FUNCTION fn_TongPhuCap_NV(@MaNV int) RETURNS decimal(18,2) AS  
BEGIN
    DECLARE @Tong decimal(18,2); SELECT @Tong = Sum(SoTien) FROM PhuCap WHERE MaNV = @MaNV; RETURN ISNULL(@Tong,0);
END;
GO

IF OBJECT_ID('dbo.fn_TongThuongPhat_NV', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TongThuongPhat_NV;
GO
-- [PHÚC] [CHỨC NĂNG]: Tính tổng tiền thưởng - phạt
CREATE FUNCTION fn_TongThuongPhat_NV(@MaNV INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @Tong DECIMAL(18,2); SELECT @Tong = SUM(CASE WHEN Loai = N'Thưởng' THEN SoTien WHEN Loai = N'Phạt' THEN -SoTien END) FROM ThuongPhat WHERE MaNV = @MaNV; RETURN ISNULL(@Tong,0);
END;
GO

IF OBJECT_ID('dbo.fn_TongGioTangCa_Thang', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TongGioTangCa_Thang;
GO
-- [PHÚC] [CHỨC NĂNG]: Tổng hợp giờ tăng ca trong tháng để tính lương
CREATE FUNCTION fn_TongGioTangCa_Thang(@MaNV INT, @Thang INT, @Nam INT) RETURNS DECIMAL(10,2) AS
BEGIN
    DECLARE @Tong DECIMAL(10,2); SELECT @Tong = SUM(GioTangCa) FROM BangChamCong WHERE MaNV = @MaNV AND MONTH(Ngay) = @Thang AND YEAR(Ngay) = @Nam; RETURN ISNULL(@Tong,0);
END;
GO

IF OBJECT_ID('dbo.fn_LayLuongCoBan_NV', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_LayLuongCoBan_NV;
GO
-- [PHÚC] [CHỨC NĂNG]: Lấy mức lương cơ bản hiện tại (ưu tiên HĐ, fallback về lương Chức vụ)
CREATE FUNCTION fn_LayLuongCoBan_NV(@MaNV INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @Luong DECIMAL(18,2); SELECT TOP 1 @Luong = hd.LuongCoBan FROM HopDong hd WHERE hd.MaNV = @MaNV ORDER BY hd.NgayBatDau DESC;
    IF @Luong IS NULL SELECT @Luong = lcb.MucLuong FROM NhanVien nv LEFT JOIN LuongCoban lcb ON nv.MaCV = lcb.MaCV WHERE nv.MaNV = @MaNV;
    RETURN ISNULL(@Luong,0);
END;
GO

IF OBJECT_ID('dbo.fn_TinhLuongThucNhan', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TinhLuongThucNhan;
GO
-- [PHÚC] [CHỨC NĂNG]: Công thức tính lương thực nhận cuối cùng
CREATE FUNCTION fn_TinhLuongThucNhan(@LCB DECIMAL(18,2), @TPC DECIMAL(18,2), @TTP DECIMAL(18,2), @TGTC DECIMAL(10,2)) RETURNS DECIMAL(18,2) AS
BEGIN RETURN ISNULL(@LCB,0) + ISNULL(@TPC,0) + ISNULL(@TTP,0) + ISNULL(@TGTC,0) * 50000; END;
GO

IF OBJECT_ID('dbo.fn_HopDongConHieuLuc', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_HopDongConHieuLuc;
GO
-- [PHÚC] [CHỨC NĂNG]: Kiểm tra nhân viên có hợp đồng Active không
CREATE FUNCTION fn_HopDongConHieuLuc(@MaNV int) RETURNS bit AS
BEGIN DECLARE @Kq bit; IF EXISTS(SELECT 1 FROM HopDong WHERE MaNV = @MaNV AND (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())) SET @Kq = 1; ELSE SET @Kq = 0; RETURN @Kq; END;
GO

IF OBJECT_ID('dbo.fn_LuongTong_NV', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_LuongTong_NV;
GO
-- [PHÚC] [CHỨC NĂNG]: Tính tổng thu nhập dự kiến (Lương + Phụ cấp)
CREATE FUNCTION fn_LuongTong_NV(@MaNV int) RETURNS decimal(18,2) AS
BEGIN DECLARE @Luong decimal(18,2); SELECT @Luong = ISNULL((SELECT MucLuong FROM LuongCoBan lc JOIN NhanVien nv ON nv.MaCV = lc.MaCV WHERE nv.MaNV = @MaNV),0) + dbo.fn_TongPhuCap_NV(@MaNV); RETURN @Luong; END;
GO

IF OBJECT_ID('dbo.fn_SoLuongHopDongHetHan', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_SoLuongHopDongHetHan;
GO
-- [PHÚC] [CHỨC NĂNG]: Thống kê số hợp đồng đã hết hạn
CREATE FUNCTION fn_SoLuongHopDongHetHan() RETURNS INT AS
BEGIN DECLARE @SoLuong INT; SELECT @SoLuong = COUNT(*) FROM HopDong WHERE NgayKetThuc IS NOT NULL AND NgayKetThuc < GETDATE(); RETURN ISNULL(@SoLuong, 0); END;
GO

IF OBJECT_ID('dbo.fn_TongPhuCapLoai', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TongPhuCapLoai;
GO
-- [PHÚC] [CHỨC NĂNG]: Báo cáo tổng chi phí phụ cấp theo từng loại
CREATE FUNCTION fn_TongPhuCapLoai(@LoaiPhuCap NVARCHAR(50) = NULL) RETURNS DECIMAL(18,2) AS
BEGIN DECLARE @Tong DECIMAL(18,2); SELECT @Tong = SUM(SoTien) FROM PhuCap WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap; RETURN ISNULL(@Tong, 0); END;
GO

-- ---------------------------------------------------------------------------
-- [SCU] CÁC HÀM TIỆN ÍCH & HỆ THỐNG
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.fn_LayMaNhanVienTheoEmail', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_LayMaNhanVienTheoEmail;
GO
-- [SCU] [CHỨC NĂNG]: Tìm mã nhân viên qua Email
CREATE FUNCTION fn_LayMaNhanVienTheoEmail(@Email NVARCHAR(60)) RETURNS INT AS BEGIN DECLARE @MaNV INT; SELECT TOP 1 @MaNV = MaNV FROM NhanVien WHERE Email = @Email; RETURN ISNULL(@MaNV, 0); END;
GO

IF OBJECT_ID('dbo.fn_KiemTraNhanVienTonTai', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_KiemTraNhanVienTonTai;
GO
-- [SCU] [CHỨC NĂNG]: Helper check tồn tại
CREATE FUNCTION fn_KiemTraNhanVienTonTai(@MaNV INT) RETURNS BIT AS BEGIN RETURN (SELECT CASE WHEN EXISTS(SELECT 1 FROM NhanVien WHERE MaNV = @MaNV) THEN 1 ELSE 0 END); END;
GO

IF OBJECT_ID('dbo.fn_LayQuyenTaiKhoan', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_LayQuyenTaiKhoan;
GO
-- [SCU] [CHỨC NĂNG]: Lấy quyền hạn của user đăng nhập
CREATE FUNCTION fn_LayQuyenTaiKhoan(@TenDangNhap NVARCHAR(50)) RETURNS NVARCHAR(20) AS BEGIN DECLARE @Quyen NVARCHAR(20); SELECT @Quyen = Quyen FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap; RETURN ISNULL(@Quyen, N'User'); END;
GO

IF OBJECT_ID('dbo.fn_DemNhanVienTrongPhong', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_DemNhanVienTrongPhong;
GO
-- [SCU] [CHỨC NĂNG]: Thống kê nhân sự phòng ban
CREATE FUNCTION fn_DemNhanVienTrongPhong(@MaPB INT) RETURNS INT AS BEGIN RETURN (SELECT COUNT(*) FROM NhanVien WHERE MaPB = @MaPB); END;
GO

IF OBJECT_ID('dbo.fn_TrungBinhHeSoLuong', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_TrungBinhHeSoLuong;
GO
-- [SCU] [CHỨC NĂNG]: Thống kê trung bình hệ số lương
CREATE FUNCTION fn_TrungBinhHeSoLuong() RETURNS DECIMAL(5,2) AS BEGIN RETURN (SELECT AVG(HeSoLuong) FROM ChucVu); END;
GO

-- ======================================================================================
-- PHẦN 5: THỦ TỤC (STORED PROCEDURES)
-- ======================================================================================
USE QL_LuongNV;
GO

-- 1. sp_AddNhanVien (Chung)
IF OBJECT_ID('dbo.sp_AddNhanVien', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddNhanVien;
GO
-- [CHUNG] [CHỨC NĂNG]: Thêm nhân viên mới và kiểm tra trùng Email
CREATE PROCEDURE sp_AddNhanVien @HoTen NVARCHAR(40), @NgaySinh DATE, @GioiTinh NVARCHAR(5), @DiaChi NVARCHAR(50), @DienThoai NVARCHAR(15), @Email NVARCHAR(60), @MaPB INT, @MaCV INT AS
BEGIN SET NOCOUNT ON; IF @Email IS NOT NULL AND EXISTS (SELECT * FROM NhanVien WHERE Email = @Email) BEGIN RAISERROR(N'Email đã tồn tại',16,1); RETURN; END INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV) VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV); END;
GO

-- ---------------------------------------------------------------------------
-- [PHÚC] THỦ TỤC QUẢN LÝ LƯƠNG & HỢP ĐỒNG
-- ---------------------------------------------------------------------------

-- 2. sp_ThemHopDong (Đã fix lỗi logic)
IF OBJECT_ID('dbo.sp_ThemHopDong', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ThemHopDong;
GO
-- [PHÚC] [CHỨC NĂNG]: Thêm hợp đồng lao động, kiểm tra hợp đồng cũ còn hiệu lực
CREATE PROCEDURE sp_ThemHopDong 
    @MaNV int, @NgayBatDau date, @NgayKetThuc date = null, @LoaiHD nvarchar(50), @Luongcoban decimal(18,2), @Ghichu nvarchar(200) = null 
AS 
BEGIN 
    SET NOCOUNT ON;
    -- Logic fix: (A OR B) để gom điều kiện kiểm tra
    IF EXISTS (SELECT 1 FROM HopDong WHERE MaNV = @MaNV AND ((NgayKetThuc IS NOT NULL AND NgayKetThuc > GETDATE()) OR LoaiHD = N'Không thời hạn')) 
    BEGIN 
        RAISERROR(N'Nhân viên này đang có hợp đồng còn hiệu lực!',16,1); RETURN; 
    END
    INSERT INTO HopDong(MaNV,NgayBatDau,NgayKetThuc,LoaiHD,LuongCoBan,GhiChu) VALUES (@MaNV,@NgayBatDau,@NgayKetThuc,@LoaiHD,@Luongcoban,@Ghichu);
END;
GO

-- 3. sp_ThemPhuCap
IF OBJECT_ID('dbo.sp_ThemPhuCap', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ThemPhuCap;
GO
-- [PHÚC] [CHỨC NĂNG]: Thêm phụ cấp cho nhân viên
CREATE PROCEDURE sp_ThemPhuCap @MaNV INT, @LoaiPhuCap NVARCHAR(50), @SoTien DECIMAL(18,2) AS
BEGIN SET NOCOUNT ON; IF NOT EXISTS (SELECT * FROM NhanVien WHERE MaNV = @MaNV) BEGIN RAISERROR(N'Nhân viên không tồn tại!',16,1); RETURN; END INSERT INTO PhuCap(MaNV,LoaiPhuCap,SoTien) VALUES(@MaNV,@LoaiPhuCap,@SoTien); END;
GO

-- 4. sp_QuanLyLuongCoBan
IF OBJECT_ID('dbo.sp_QuanLyLuongCoBan', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_QuanLyLuongCoBan;
GO
-- [PHÚC] [CHỨC NĂNG]: CRUD bảng Lương Cơ Bản
CREATE PROCEDURE sp_QuanLyLuongCoBan @HanhDong NVARCHAR(10), @MaCV INT, @MucLuong DECIMAL(18,2) = NULL AS
BEGIN SET NOCOUNT ON; BEGIN TRY BEGIN TRANSACTION; IF @HanhDong = 'Thêm' INSERT INTO LuongCoBan(MaCV,MucLuong) VALUES (@MaCV,@MucLuong); ELSE IF @HanhDong = 'Sửa' UPDATE LuongCoBan SET MucLuong = @MucLuong WHERE MaCV = @MaCV; ELSE IF @HanhDong = 'Xóa' DELETE FROM LuongCoBan WHERE MaCV = @MaCV; ELSE RAISERROR(N'Hành động không hợp lệ!',16,1); COMMIT TRANSACTION; END TRY BEGIN CATCH ROLLBACK TRANSACTION; DECLARE @Loi NVARCHAR(4000) = ERROR_MESSAGE(); RAISERROR(@Loi,16,1); END CATCH END;
GO

-- 5. sp_TinhBangLuong_Thang
IF OBJECT_ID('dbo.sp_TinhBangLuong_Thang', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_TinhBangLuong_Thang;
GO
-- [PHÚC] [CHỨC NĂNG]: Tính toán bảng lương tháng (xóa cũ, tính mới dựa trên các hàm con)
CREATE PROCEDURE sp_TinhBangLuong_Thang @Thang INT, @Nam INT AS
BEGIN SET NOCOUNT ON; DELETE FROM BangLuong WHERE Thang = @Thang AND Nam = @Nam; INSERT INTO BangLuong (MaNV,Thang,Nam,LuongCoBan,TongPhuCap,TongThuongPhat,TongGioTangCa) SELECT nv.MaNV,@Thang,@Nam, ISNULL(hd.LuongCoBan,ISNULL(lcb.MucLuong,0)), ISNULL((SELECT SUM(SoTien) FROM PhuCap pc WHERE pc.MaNV = nv.MaNV),0), ISNULL((SELECT SUM(CASE WHEN tp.Loai = N'Thưởng' THEN tp.SoTien WHEN tp.Loai = N'Phạt' THEN -tp.SoTien END) FROM ThuongPhat tp WHERE tp.MaNV = nv.MaNV),0), ISNULL((SELECT SUM(cc.GioTangCa) FROM BangChamCong cc WHERE cc.MaNV = nv.MaNV AND MONTH(cc.Ngay)=@Thang AND YEAR(cc.Ngay)=@Nam),0) FROM NhanVien nv LEFT JOIN HopDong hd ON nv.MaNV = hd.MaNV LEFT JOIN LuongCoban lcb ON nv.MaCV = lcb.MaCV GROUP BY nv.MaNV, hd.LuongCoBan, lcb.MucLuong; END;
GO

-- 6. sp_ThemThuongPhat_AndCapNhatBangLuong
IF OBJECT_ID('dbo.sp_ThemThuongPhat_AndCapNhatBangLuong', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ThemThuongPhat_AndCapNhatBangLuong;
GO
-- [PHÚC] [CHỨC NĂNG]: Thêm thưởng phạt và tự động update vào bảng lương tháng hiện tại
CREATE PROCEDURE sp_ThemThuongPhat_AndCapNhatBangLuong @MaNV INT, @Loai NVARCHAR(20), @SoTien DECIMAL(18,2), @LyDo NVARCHAR(200) AS 
BEGIN SET NOCOUNT ON; BEGIN TRY BEGIN TRANSACTION; INSERT INTO ThuongPhat(MaNV,Loai,SoTien,LyDo) VALUES(@MaNV,@Loai,@SoTien,@LyDo); UPDATE BangLuong SET TongThuongPhat = ISNULL(TongThuongPhat,0) + CASE WHEN @Loai = N'Thưởng' THEN @SoTien ELSE -@SoTien END WHERE MaNV = @MaNV AND Thang = MONTH(GETDATE()) AND Nam = YEAR(GETDATE()); COMMIT TRANSACTION; END TRY BEGIN CATCH ROLLBACK TRANSACTION; THROW; END CATCH END;
GO

-- 7. sp_DanhSachHopDongNV
IF OBJECT_ID('dbo.sp_DanhSachHopDongNV', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_DanhSachHopDongNV;
GO
-- [PHÚC] [CHỨC NĂNG]: Liệt kê hợp đồng của nhân viên
CREATE PROCEDURE sp_DanhSachHopDongNV @MaNV int = null AS BEGIN SET NOCOUNT ON; SELECT * FROM HopDong WHERE @MaNV IS NULL OR MaNV = @MaNV; END;
GO

-- 8. sp_TongPhuCapTheoLoai
IF OBJECT_ID('dbo.sp_TongPhuCapTheoLoai', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_TongPhuCapTheoLoai;
GO
-- [PHÚC] [CHỨC NĂNG]: Báo cáo tổng chi phí phụ cấp
CREATE PROCEDURE sp_TongPhuCapTheoLoai @LoaiPhuCap nvarchar(50) = null AS BEGIN SET NOCOUNT ON; SELECT LoaiPhuCap, SUM(SoTien) as TongPhuCap FROM PhuCap WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap GROUP BY LoaiPhuCap; END;
GO

-- ---------------------------------------------------------------------------
-- [SCU] THỦ TỤC QUẢN LÝ HỆ THỐNG & DANH MỤC
-- ---------------------------------------------------------------------------

-- 9. sp_TaoTaiKhoan
IF OBJECT_ID('dbo.sp_TaoTaiKhoan', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_TaoTaiKhoan;
GO
-- [SCU] [CHỨC NĂNG]: Tạo tài khoản đăng nhập Web cho nhân viên
CREATE PROCEDURE sp_TaoTaiKhoan @TenDangNhap NVARCHAR(50), @MatKhau NVARCHAR(100), @MaNV INT, @Quyen NVARCHAR(20) = N'User', @MaRole INT = 4 AS
BEGIN SET NOCOUNT ON; IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV=@MaNV) BEGIN RAISERROR (N'Nhân viên không tồn tại',16,1); RETURN; END IF EXISTS (SELECT 1 FROM TaiKhoan WHERE TenDangNhap=@TenDangNhap) BEGIN RAISERROR (N'Tên đăng nhập đã tồn tại',16,1); RETURN; END IF @MaRole IS NULL SELECT @MaRole = MaRole FROM Roles WHERE TenRole = @Quyen; INSERT INTO TaiKhoan(TenDangNhap,MatKhau,MaNV,Quyen,MaRole) VALUES(@TenDangNhap,@MatKhau,@MaNV,@Quyen,@MaRole); END;
GO

-- 10. sp_CapNhatTrangThaiNV
IF OBJECT_ID('dbo.sp_CapNhatTrangThaiNV', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CapNhatTrangThaiNV;
GO
-- [SCU] [CHỨC NĂNG]: Quét toàn bộ hệ thống, ai hết hạn hợp đồng thì set nghỉ việc
CREATE PROCEDURE sp_CapNhatTrangThaiNV AS BEGIN SET NOCOUNT ON; UPDATE NhanVien SET TrangThai = N'Nghỉ việc' WHERE MaNV NOT IN (SELECT MaNV FROM HopDong WHERE (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())); END;
GO

-- 11. sp_QuanLyPhongBan
IF OBJECT_ID('dbo.sp_QuanLyPhongBan', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_QuanLyPhongBan;
GO
-- [SCU] [CHỨC NĂNG]: CRUD Phòng Ban
CREATE PROCEDURE sp_QuanLyPhongBan @ThaoTac NVARCHAR(10), @MaPB INT = NULL, @TenPB NVARCHAR(50) = NULL AS BEGIN IF @ThaoTac = 'THEM' INSERT INTO PhongBan(TenPB) VALUES(@TenPB); ELSE IF @ThaoTac = 'SUA' UPDATE PhongBan SET TenPB = @TenPB WHERE MaPB = @MaPB; ELSE IF @ThaoTac = 'XOA' DELETE FROM PhongBan WHERE MaPB = @MaPB; END;
GO

-- 12. sp_QuanLyChucVu
IF OBJECT_ID('dbo.sp_QuanLyChucVu', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_QuanLyChucVu;
GO
-- [SCU] [CHỨC NĂNG]: CRUD Chức vụ
CREATE PROCEDURE sp_QuanLyChucVu @ThaoTac NVARCHAR(10), @MaCV INT = NULL, @TenCV NVARCHAR(50) = NULL, @HeSoLuong DECIMAL(4,2) = NULL AS BEGIN IF @ThaoTac = 'THEM' INSERT INTO ChucVu(TenCV, HeSoLuong) VALUES(@TenCV, @HeSoLuong); ELSE IF @ThaoTac = 'SUA' UPDATE ChucVu SET TenCV = @TenCV, HeSoLuong = @HeSoLuong WHERE MaCV = @MaCV; ELSE IF @ThaoTac = 'XOA' DELETE FROM ChucVu WHERE MaCV = @MaCV; END;
GO

-- 13. sp_TaoBackup_QLLuong
IF OBJECT_ID('dbo.sp_TaoBackup_QLLuong', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_TaoBackup_QLLuong;
GO
-- [SCU] [CHỨC NĂNG]: Backup Database tự động
CREATE PROCEDURE sp_TaoBackup_QLLuong AS BEGIN DECLARE @File NVARCHAR(300); SET @File = 'D:\Backup_QLLuong\QL_Luong_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak'; BACKUP DATABASE QL_LuongNV TO DISK = @File WITH INIT, FORMAT, NAME = 'Backup tu dong CSDL QL_Luong', SKIP, NOREWIND, NOUNLOAD, STATS = 10; END;
GO

-- ==================== 6. TRIGGERS (TỰ ĐỘNG HÓA) ====================
USE QL_LuongNV;
GO

-- [PHÚC] TRIGGER LIÊN QUAN ĐẾN TIỀN VÀ HỢP ĐỒNG
IF OBJECT_ID('trg_AfterInsert_ThuongPhat', 'TR') IS NOT NULL DROP TRIGGER trg_AfterInsert_ThuongPhat;
GO
-- [PHÚC] [CHỨC NĂNG]: Thêm thưởng phạt -> Cộng luôn vào bảng lương
CREATE TRIGGER trg_AfterInsert_ThuongPhat ON ThuongPhat AFTER INSERT AS BEGIN SET NOCOUNT ON; UPDATE bl SET TongThuongPhat = ISNULL(bl.TongThuongPhat,0) + ISNULL(s.AddValue,0) FROM BangLuong bl JOIN (SELECT i.MaNV, SUM(CASE WHEN i.Loai = N'Thưởng' THEN i.SoTien WHEN i.Loai = N'Phạt' THEN -i.SoTien END) AS AddValue FROM inserted i GROUP BY i.MaNV) s ON bl.MaNV = s.MaNV WHERE bl.Thang = MONTH(GETDATE()) AND bl.Nam = YEAR(GETDATE()); END;
GO

IF OBJECT_ID('tr_HopDong_AfterUpdate', 'TR') IS NOT NULL DROP TRIGGER tr_HopDong_AfterUpdate;
GO
-- [PHÚC] [CHỨC NĂNG]: Sửa hợp đồng hết hạn -> Set nhân viên nghỉ việc
CREATE TRIGGER tr_HopDong_AfterUpdate ON HopDong AFTER UPDATE AS BEGIN UPDATE NhanVien SET TrangThai = N'Nghỉ việc' WHERE MaNV IN(SELECT i.MaNV FROM inserted i WHERE i.NgayKetThuc < GETDATE()); END;
GO

IF OBJECT_ID('tr_HopDong_AlterInsert', 'TR') IS NOT NULL DROP TRIGGER tr_HopDong_AlterInsert;
GO
-- [PHÚC] [CHỨC NĂNG]: Thêm hợp đồng mới -> Set nhân viên Đang làm
CREATE TRIGGER tr_HopDong_AlterInsert ON HopDong AFTER INSERT AS BEGIN UPDATE NhanVien SET TrangThai = N'Đang làm' WHERE MaNV IN (SELECT i.MaNV FROM inserted i WHERE i.NgayKetThuc IS NULL OR i.NgayKetThuc > GETDATE()); END;
GO

IF OBJECT_ID('tr_NhanVien_AfterUpdate', 'TR') IS NOT NULL DROP TRIGGER tr_NhanVien_AfterUpdate;
GO
-- [PHÚC] [CHỨC NĂNG]: Đổi chức vụ nhân viên -> Cập nhật Lương hiện tại theo chức vụ mới
CREATE TRIGGER tr_NhanVien_AfterUpdate ON NhanVien AFTER UPDATE AS BEGIN UPDATE nv SET nv.LuongHienTai = lc.MucLuong FROM NhanVien nv JOIN inserted i ON nv.MaNV = i.MaNV JOIN LuongCoban lc ON i.MaCV = lc.MaCV WHERE i.MaCV <> (SELECT d.MaCV FROM deleted d WHERE d.MaNV = i.MaNV); END;
GO

IF OBJECT_ID('tr_LuongCoBan_AfterUpdate', 'TR') IS NOT NULL DROP TRIGGER tr_LuongCoBan_AfterUpdate;
GO
-- [PHÚC] [CHỨC NĂNG]: Log lịch sử thay đổi lương cơ bản
CREATE TRIGGER tr_LuongCoBan_AfterUpdate ON LuongCoBan AFTER UPDATE AS BEGIN INSERT INTO LuongCoBanLog(MaCV, MucLuongCu, MucLuongMoi) SELECT d.MaCV, d.MucLuong, i.MucLuong FROM inserted i JOIN deleted d ON i.MaCV = d.MaCV WHERE i.MucLuong <> d.MucLuong; END;
GO

IF OBJECT_ID('trg_TaoBangLuongKhiThemNV', 'TR') IS NOT NULL DROP TRIGGER trg_TaoBangLuongKhiThemNV;
GO
-- [PHÚC] [CHỨC NĂNG]: Nhân viên mới -> Tạo dòng bảng lương trống
CREATE TRIGGER trg_TaoBangLuongKhiThemNV ON NhanVien AFTER INSERT AS BEGIN INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa) SELECT MaNV, MONTH(GETDATE()), YEAR(GETDATE()), 0, 0, 0, 0 FROM inserted; END;
GO

-- [SCU] TRIGGER HỆ THỐNG VÀ PHÒNG BAN
IF OBJECT_ID('trg_PreventDuplicate_ChanCong', 'TR') IS NOT NULL DROP TRIGGER trg_PreventDuplicate_ChanCong;
GO
-- [SCU] [CHỨC NĂNG]: Chặn chấm công 2 lần/ngày
CREATE TRIGGER trg_PreventDuplicate_ChanCong ON BangChamCong AFTER INSERT AS BEGIN SET NOCOUNT ON; IF EXISTS (SELECT 1 FROM BangChamCong c JOIN inserted i ON c.MaNV = i.MaNV AND c.Ngay = i.Ngay GROUP BY c.MaNV, c.Ngay HAVING COUNT(*) > 1) BEGIN RAISERROR(N'Chấm công trùng ngày!',16,1); ROLLBACK TRANSACTION; END END;
GO

IF OBJECT_ID('trg_Log_Delete_NhanVien', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_NhanVien;
GO
-- [SCU] [CHỨC NĂNG]: Log lịch sử khi xóa nhân viên
CREATE TRIGGER trg_Log_Delete_NhanVien ON NhanVien AFTER DELETE AS BEGIN INSERT INTO LichSuXoaNhanVien(MaNV, HoTen, NgayXoa, LyDo) SELECT d.MaNV, d.HoTen, GETDATE(), N'Xóa nhân viên' FROM deleted d; END;
GO

IF OBJECT_ID('trg_Log_TaoTaiKhoan', 'TR') IS NOT NULL DROP TRIGGER trg_Log_TaoTaiKhoan;
GO
-- [SCU] [CHỨC NĂNG]: Log lịch sử tạo tài khoản
CREATE TRIGGER trg_Log_TaoTaiKhoan ON TaiKhoan AFTER INSERT AS BEGIN INSERT INTO LichSuTaiKhoan(MaNV, TenDangNhap, NgayTao) SELECT MaNV, TenDangNhap, GETDATE() FROM inserted; END;
GO

IF OBJECT_ID('trg_SetNull_MaPB_WhenPhongBanXoa', 'TR') IS NOT NULL DROP TRIGGER trg_SetNull_MaPB_WhenPhongBanXoa;
GO
-- [SCU] [CHỨC NĂNG]: Xóa phòng ban -> Set nhân viên thuộc phòng đó về NULL (không xóa nhân viên)
CREATE TRIGGER trg_SetNull_MaPB_WhenPhongBanXoa ON PhongBan AFTER DELETE AS BEGIN UPDATE NhanVien SET MaPB = NULL WHERE MaPB IN (SELECT MaPB FROM deleted); END;
GO

IF OBJECT_ID('trg_CapNhatLuongKhiDoiHeSo', 'TR') IS NOT NULL DROP TRIGGER trg_CapNhatLuongKhiDoiHeSo;
GO
-- [SCU] [CHỨC NĂNG]: Đổi hệ số chức vụ -> Tính lại lương cơ bản
CREATE TRIGGER trg_CapNhatLuongKhiDoiHeSo ON ChucVu AFTER UPDATE AS BEGIN UPDATE b SET b.LuongCoBan = c.HeSoLuong * 1000000 FROM BangLuong b INNER JOIN NhanVien n ON b.MaNV = n.MaNV INNER JOIN inserted c ON n.MaCV = c.MaCV; END;
GO

-- ======================================================================================
-- PHẦN 7: SINH DỮ LIỆU TỰ ĐỘNG (AN TOÀN TUYỆT ĐỐI) - [PHÚC]
-- ======================================================================================
USE QL_LuongNV;
GO

DECLARE @i INT = 1;
DECLARE @TargetCount INT = 300;
DECLARE @HoTen NVARCHAR(40), @Ho NVARCHAR(10), @Dem NVARCHAR(10), @Ten NVARCHAR(10);
DECLARE @GioiTinh NVARCHAR(5), @NgaySinh DATE, @DiaChi NVARCHAR(50), @DienThoai NVARCHAR(15), @Email NVARCHAR(60);
DECLARE @MaPB INT, @MaCV INT, @NewMaNV INT;

DECLARE @ListHo TABLE (Val NVARCHAR(10));
INSERT INTO @ListHo VALUES (N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Huỳnh'), (N'Hoàng'), (N'Phan'), (N'Vũ'), (N'Võ'), (N'Đặng'), (N'Bùi'), (N'Đỗ'), (N'Hồ'), (N'Ngô'), (N'Dương');
DECLARE @ListDem TABLE (Val NVARCHAR(10));
INSERT INTO @ListDem VALUES (N'Văn'), (N'Thị'), (N'Minh'), (N'Hữu'), (N'Ngọc'), (N'Đức'), (N'Thành'), (N'Quang'), (N'Xuân'), (N'Hải'), (N'Thanh'), (N'Mạnh'), (N'Kim');
DECLARE @ListTen TABLE (Val NVARCHAR(10));
INSERT INTO @ListTen VALUES (N'An'), (N'Bình'), (N'Cường'), (N'Dũng'), (N'Giang'), (N'Hùng'), (N'Hương'), (N'Khánh'), (N'Lan'), (N'Minh'), (N'Nam'), (N'Nga'), (N'Oanh'), (N'Phúc'), (N'Quân'), (N'Sơn'), (N'Tuấn'), (N'Uyên'), (N'Vy'), (N'Yến'), (N'Tâm'), (N'Thảo');
DECLARE @ListDiaChi TABLE (Val NVARCHAR(50));
INSERT INTO @ListDiaChi VALUES (N'Hà Nội'), (N'TP.HCM'), (N'Đà Nẵng'), (N'Hải Phòng'), (N'Cần Thơ'), (N'Nghệ An'), (N'Thanh Hóa'), (N'Bắc Ninh'), (N'Bình Dương'), (N'Đồng Nai'), (N'Vĩnh Phúc'), (N'Quảng Ninh');
DECLARE @ListPhuCap TABLE (Loai NVARCHAR(50), Tien DECIMAL(18,2));
INSERT INTO @ListPhuCap VALUES (N'Xăng xe', 500000), (N'Điện thoại', 300000), (N'Ăn trưa', 700000), (N'Trách nhiệm', 2000000), (N'Độc hại', 1000000);

PRINT N'>>> BẮT ĐẦU QUÁ TRÌNH TỰ ĐỘNG SINH ' + CAST(@TargetCount AS NVARCHAR(10)) + N' NHÂN VIÊN (MODULE CỦA PHÚC)...';

WHILE @i <= @TargetCount
BEGIN
    BEGIN TRY
        -- Random data
        SELECT TOP 1 @Ho = Val FROM @ListHo ORDER BY NEWID();
        SELECT TOP 1 @Dem = Val FROM @ListDem ORDER BY NEWID();
        SELECT TOP 1 @Ten = Val FROM @ListTen ORDER BY NEWID();
        SET @HoTen = @Ho + ' ' + @Dem + ' ' + @Ten;
        IF @Dem = N'Thị' SET @GioiTinh = N'Nữ' ELSE SET @GioiTinh = N'Nam';
        IF (ABS(CHECKSUM(NEWID())) % 10) < 3 SET @GioiTinh = CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN N'Nam' ELSE N'Nữ' END;
        SET @NgaySinh = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 11000) - 8000, GETDATE()); 
        SELECT TOP 1 @DiaChi = Val FROM @ListDiaChi ORDER BY NEWID();
        SET @DienThoai = '09' + RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(10)), 8);
        SET @Email = LOWER(LEFT(@Ten, 1) + LEFT(@Ho, 1) + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(10))) + '@company.vn';
        SET @MaPB = (ABS(CHECKSUM(NEWID())) % 6) + 1;
        IF (ABS(CHECKSUM(NEWID())) % 10) < 7 SET @MaCV = 1; ELSE SET @MaCV = (ABS(CHECKSUM(NEWID())) % 4) + 2;

        -- Insert
        INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV, TrangThai)
        VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV, N'Đang làm');
        
        SET @NewMaNV = SCOPE_IDENTITY();

        -- Hợp đồng
        DECLARE @LuongRandom DECIMAL(18,2) = (ABS(CHECKSUM(NEWID())) % 23000000) + 7000000;
        DECLARE @NgayBatDau Date = DATEADD(MONTH, - (ABS(CHECKSUM(NEWID())) % 24), GETDATE());
        EXEC sp_ThemHopDong @MaNV = @NewMaNV, @NgayBatDau = @NgayBatDau, @NgayKetThuc = NULL, @LoaiHD = N'Không thời hạn', @Luongcoban = @LuongRandom, @Ghichu = N'Hợp đồng chính thức';

        -- Phụ cấp
        IF (ABS(CHECKSUM(NEWID())) % 2) = 0 
        BEGIN
            DECLARE @PhuCapLoai NVARCHAR(50); DECLARE @PhuCapTien DECIMAL(18,2);
            SELECT TOP 1 @PhuCapLoai = Loai, @PhuCapTien = Tien FROM @ListPhuCap ORDER BY NEWID();
            EXEC sp_ThemPhuCap @MaNV = @NewMaNV, @LoaiPhuCap = @PhuCapLoai, @SoTien = @PhuCapTien;
        END

        -- Tài khoản
        DECLARE @Username NVARCHAR(50) = LEFT(@Email, CHARINDEX('@', @Email) - 1);
        DECLARE @RoleID INT = 4; 
        IF @MaCV = 3 SET @RoleID = 1; IF @MaCV = 5 SET @RoleID = 3; 

        IF NOT EXISTS (SELECT 1 FROM TaiKhoan WHERE TenDangNhap = @Username)
        BEGIN
            EXEC sp_TaoTaiKhoan @TenDangNhap = @Username, @MatKhau = N'123456', @MaNV = @NewMaNV, @Quyen = N'User', @MaRole = @RoleID;
        END

        SET @i = @i + 1;
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi ở dòng ' + CAST(@i AS NVARCHAR(10)) + N': ' + ERROR_MESSAGE();
        SET @i = @i + 1; 
    END CATCH
END;
PRINT N'>>> ĐÃ TẠO XONG DỮ LIỆU.';
GO

-- ======================================================================================
-- PHẦN 8: BẢO MẬT & PHÂN QUYỀN
-- ======================================================================================
USE QL_LuongNV;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_NhanSu') CREATE ROLE role_NhanSu;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_KeToan') CREATE ROLE role_KeToan;
GO

-- Cấp quyền cho Nhân sự (SCU phụ trách logic này)
GRANT SELECT, INSERT, UPDATE, DELETE ON NhanVien TO role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON PhongBan TO role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON ChucVu TO role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON HopDong TO role_NhanSu;
GRANT SELECT, INSERT, UPDATE, DELETE ON BangChamCong TO role_NhanSu;
GRANT EXECUTE ON sp_AddNhanVien TO role_NhanSu;
GRANT EXECUTE ON sp_ThemHopDong TO role_NhanSu;
GRANT EXECUTE ON sp_QuanLyPhongBan TO role_NhanSu;
GRANT EXECUTE ON sp_QuanLyChucVu TO role_NhanSu;
GRANT EXECUTE ON sp_DanhSachHopDongNV TO role_NhanSu;

-- Cấp quyền cho Kế toán (PHÚC phụ trách logic này)
GRANT SELECT, INSERT, UPDATE, DELETE ON BangLuong TO role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON PhuCap TO role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON ThuongPhat TO role_KeToan;
GRANT SELECT, INSERT, UPDATE, DELETE ON LuongCoBan TO role_KeToan;
GRANT SELECT ON NhanVien TO role_KeToan;
GRANT SELECT ON HopDong TO role_KeToan;
GRANT SELECT ON BangChamCong TO role_KeToan;
GRANT EXECUTE ON sp_TinhBangLuong_Thang TO role_KeToan;
GRANT EXECUTE ON sp_ThemPhuCap TO role_KeToan;
GRANT EXECUTE ON sp_QuanLyLuongCoBan TO role_KeToan;
GRANT EXECUTE ON sp_TongPhuCapTheoLoai TO role_KeToan;
GO

USE master;
GO
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'NhanSuLogin') DROP LOGIN NhanSuLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'KeToanLogin') DROP LOGIN KeToanLogin;
CREATE LOGIN NhanSuLogin WITH PASSWORD = N'NhanSu@12345', DEFAULT_DATABASE = QL_LuongNV, CHECK_POLICY = OFF;
CREATE LOGIN KeToanLogin WITH PASSWORD = N'KeToan@12345', DEFAULT_DATABASE = QL_LuongNV, CHECK_POLICY = OFF;
GO

USE QL_LuongNV;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'NhanSuUser') DROP USER NhanSuUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'KeToanUser') DROP USER KeToanUser;
CREATE USER NhanSuUser FOR LOGIN NhanSuLogin;
CREATE USER KeToanUser FOR LOGIN KeToanLogin;
ALTER ROLE role_NhanSu ADD MEMBER NhanSuUser;
ALTER ROLE role_KeToan ADD MEMBER KeToanUser;
GO

PRINT N'*** HOÀN TẤT 100% ***';