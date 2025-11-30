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
    Thangg int check(Thangg BETWEEN 1 AND 12),
    Namm int check(Namm >=2000),
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
INSERT INTO ThuongPhat(MaNV, Thangg, Namm, Loai, SoTien, LyDo)
VALUES
(1, 10, 2024, N'Thưởng', 1000000, N'Hoàn thành tốt công việc'),
(2, 10, 2024, N'Phạt', 300000, N'Đi muộn'),
(3, 10, 2024, N'Thưởng', 2000000, N'Dự án xuất sắc'),
(4, 10, 2024, N'Thưởng', 500000, N'Đạt chỉ tiêu tháng'),
(5, 10, 2024, N'Phạt', 200000, N'Nghỉ không phép'),
(6, 10, 2024, N'Thưởng', 1000000, N'Ý tưởng sáng tạo'),
(7, 10, 2024, N'Thưởng', 800000, N'Hỗ trợ nhóm tốt'),
(8, 10, 2024, N'Phạt', 300000, N'Đi muộn 2 lần'),
(9, 10, 2024, N'Thưởng', 1500000, N'Quản lý xuất sắc');
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


SELECT TOP 5 
    T.TenDangNhap, 
    '123456' AS MatKhau, 
    N.HoTen, 
    CV.TenCV AS ChucVu, 
    'Admin' AS QuyenWeb
FROM TaiKhoan T
JOIN NhanVien N ON T.MaNV = N.MaNV
JOIN ChucVu CV ON N.MaCV = CV.MaCV
WHERE T.MaRole = 1; -- Role Admin

PRINT N'=== DANH SÁCH TÀI KHOẢN KẾ TOÁN (Quản lý lương) ===';
SELECT TOP 5 
    T.TenDangNhap, 
    '123456' AS MatKhau, 
    N.HoTen, 
    CV.TenCV AS ChucVu, 
    'KeToan' AS QuyenWeb
FROM TaiKhoan T
JOIN NhanVien N ON T.MaNV = N.MaNV
JOIN ChucVu CV ON N.MaCV = CV.MaCV
WHERE T.MaRole = 3; -- Role KeToan

PRINT N'=== DANH SÁCH TÀI KHOẢN NHÂN VIÊN (Chỉ xem cá nhân) ===';
SELECT TOP 5 
    T.TenDangNhap, 
    '123456' AS MatKhau, 
    N.HoTen, 
    CV.TenCV AS ChucVu, 
    'User' AS QuyenWeb
FROM TaiKhoan T
JOIN NhanVien N ON T.MaNV = N.MaNV
JOIN ChucVu CV ON N.MaCV = CV.MaCV
WHERE T.MaRole = 4; -- Role NhanVien

select * from TaiKhoan-- ======================================================================================
-- UC8: FUNCTION TÍNH TỔNG GIỜ TĂNG CA TRONG THÁNG
-- ======================================================================================
-- Mục đích: Tính tổng số giờ làm thêm của 1 nhân viên trong 1 tháng cụ thể
-- Sử dụng: Để tính lương tăng ca (Lương tăng ca = Tổng giờ × 50,000 VNĐ/giờ)
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa function cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.fn_TongGioTangCa_Thang', 'FN') IS NOT NULL 
    DROP FUNCTION dbo.fn_TongGioTangCa_Thang;
GO

-- [UC8] [CHỨC NĂNG]: Tổng hợp giờ tăng ca trong tháng để tính lương
CREATE FUNCTION fn_TongGioTangCa_Thang(
    @MaNV_BangChamCong INT,      -- Mã nhân viên cần tính giờ tăng ca
    @Thang_BangLuong INT,        -- Tháng cần tính (1-12)
    @Nam_BangLuong INT           -- Năm cần tính (VD: 2025)
) 
RETURNS DECIMAL(10,2)            -- Trả về tổng giờ tăng ca (VD: 25.50 giờ)
AS
BEGIN
    /*
     * LOGIC TÍNH TOÁN:
     * 1. Lọc tất cả bản ghi chấm công của nhân viên (@MaNV_BangChamCong)
     * 2. Trong tháng và năm được chỉ định (@Thang_BangLuong, @Nam_BangLuong)
     * 3. Sử dụng hàm MONTH() và YEAR() để trích xuất tháng/năm từ cột Ngay
     * 4. Tính tổng (SUM) cột GioTangCa
     * 5. Trả về 0 nếu không có dữ liệu (ISNULL)
     */
    
    -- Biến lưu kết quả tổng giờ tăng ca
    DECLARE @TongGio_BangChamCong DECIMAL(10,2);
    
    -- Truy vấn tính tổng giờ tăng ca
    SELECT @TongGio_BangChamCong = SUM(GioTangCa) 
    FROM BangChamCong 
    WHERE MaNV = @MaNV_BangChamCong                    -- Lọc theo mã nhân viên
      AND MONTH(Ngay) = @Thang_BangLuong               -- Lọc theo tháng
      AND YEAR(Ngay) = @Nam_BangLuong;                 -- Lọc theo năm
    
    -- Trả về kết quả (nếu NULL thì trả về 0)
    RETURN ISNULL(@TongGio_BangChamCong, 0);
END;
GO

PRINT N'✓ Function fn_TongGioTangCa_Thang đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6: FUNCTION TÍNH TỔNG NGÀY CÔNG TRONG THÁNG
-- ======================================================================================
-- Tên: fn_TinhTongNgayCong
-- Mục đích: Tính tổng số ngày công thực tế của 1 nhân viên trong 1 tháng cụ thể
-- Sử dụng: Để kiểm tra hiệu suất làm việc, tính lương theo ngày công
-- Kết quả: Trả về tổng ngày công (VD: 22.5 ngày)
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa function cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.fn_TinhTongNgayCong', 'FN') IS NOT NULL 
    DROP FUNCTION dbo.fn_TinhTongNgayCong;
GO

-- [UC6] [CHỨC NĂNG]: Tính tổng ngày công của nhân viên trong tháng
CREATE FUNCTION fn_TinhTongNgayCong(
    @MaNV_Input INT,             -- Mã nhân viên cần tính
    @Thang_Input INT,            -- Tháng cần tính (1-12)
    @Nam_Input INT               -- Năm cần tính (VD: 2025)
) 
RETURNS DECIMAL(10,2)            -- Trả về tổng ngày công (VD: 22.5 ngày)
AS
BEGIN
    /*
     * LOGIC TÍNH TOÁN:
     * 1. Lọc tất cả bản ghi chấm công của nhân viên (@MaNV_Input)
     * 2. Trong tháng và năm được chỉ định (@Thang_Input, @Nam_Input)
     * 3. Sử dụng hàm MONTH() và YEAR() để trích xuất tháng/năm từ cột Ngay
     * 4. Tính tổng (SUM) cột NgayCong
     * 5. Trả về 0 nếu không có dữ liệu (ISNULL)
     * 
     * LƯU Ý:
     * - NgayCong có thể là 0.5 (nửa ngày), 1.0 (cả ngày)
     * - Tổng ngày công thường từ 20-26 ngày/tháng
     */
    
    -- Biến lưu kết quả tổng ngày công
    DECLARE @TongNgayCong DECIMAL(10,2);
    
    -- Truy vấn tính tổng ngày công
    SELECT @TongNgayCong = SUM(NgayCong) 
    FROM BangChamCong 
    WHERE MaNV = @MaNV_Input                    -- Lọc theo mã nhân viên
      AND MONTH(Ngay) = @Thang_Input            -- Lọc theo tháng
      AND YEAR(Ngay) = @Nam_Input;              -- Lọc theo năm
    
    -- Trả về kết quả (nếu NULL thì trả về 0)
    RETURN ISNULL(@TongNgayCong, 0);
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- Tính tổng ngày công của nhân viên mã 1 trong tháng 11/2025
SELECT dbo.fn_TinhTongNgayCong(1, 11, 2025) AS N'Tổng ngày công';

-- Sử dụng trong truy vấn để xem tất cả nhân viên
SELECT 
    MaNV,
    HoTen,
    dbo.fn_TinhTongNgayCong(MaNV, 11, 2025) AS N'Ngày công tháng 11/2025'
FROM NhanVien
ORDER BY MaNV;

-- Tính tỷ lệ đi làm (so với 26 ngày làm việc tiêu chuẩn)
SELECT 
    MaNV,
    HoTen,
    dbo.fn_TinhTongNgayCong(MaNV, 11, 2025) AS N'Ngày công thực tế',
    CAST(ROUND(dbo.fn_TinhTongNgayCong(MaNV, 11, 2025) * 100.0 / 26, 2) AS NVARCHAR(10)) + '%' AS N'Tỷ lệ đi làm'
FROM NhanVien
ORDER BY MaNV;

KẾT QUẢ:
- Trả về số ngày công (VD: 22.5 nghĩa là 22 ngày rưỡi)
- Trả về 0 nếu nhân viên không có chấm công trong tháng
*/

PRINT N'✓ Function fn_TinhTongNgayCong đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC13: FUNCTION TÍNH LƯƠNG THỰC NHẬN
-- ======================================================================================
-- Tên: fn_TinhLuongThucNhan
-- Mục đích: Tính lương thực nhận dựa trên các thành phần lương
-- Sử dụng: Để tính lương trước khi lưu vào BangLuong, kiểm tra lương
-- Công thức: Lương thực nhận = Lương cơ bản + Phụ cấp + Thưởng/Phạt + (Giờ tăng ca × 50,000)
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa function cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.fn_TinhLuongThucNhan', 'FN') IS NOT NULL 
    DROP FUNCTION dbo.fn_TinhLuongThucNhan;
GO

-- [UC13] [CHỨC NĂNG]: Tính lương thực nhận từ các thành phần lương
CREATE FUNCTION fn_TinhLuongThucNhan(
    @LuongCoBan DECIMAL(18,2),       -- Lương cơ bản (VD: 10,000,000)
    @TongPhuCap DECIMAL(18,2),       -- Tổng phụ cấp (VD: 2,000,000)
    @TongThuongPhat DECIMAL(18,2),   -- Tổng thưởng/phạt (VD: 500,000 hoặc -200,000)
    @TongGioTangCa DECIMAL(10,2)     -- Tổng giờ tăng ca (VD: 25.5 giờ)
) 
RETURNS DECIMAL(18,2)                -- Trả về lương thực nhận (VD: 13,775,000)
AS
BEGIN
    /*
     * CÔNG THỨC TÍNH LƯƠNG:
     * 
     * Lương thực nhận = Lương cơ bản 
     *                 + Tổng phụ cấp 
     *                 + Tổng thưởng/phạt 
     *                 + (Tổng giờ tăng ca × 50,000 VNĐ/giờ)
     * 
     * CHI TIẾT CÁC THÀNH PHẦN:
     * 
     * 1. LƯƠNG CƠ BẢN (@LuongCoBan):
     *    - Lương theo hợp đồng hoặc theo chức vụ
     *    - Là thành phần chính, chiếm 60-80% tổng lương
     * 
     * 2. TỔNG PHỤ CẤP (@TongPhuCap):
     *    - Phụ cấp xăng xe, điện thoại, ăn trưa, v.v.
     *    - Luôn là số dương
     * 
     * 3. TỔNG THƯỞNG/PHẠT (@TongThuongPhat):
     *    - Thưởng: Số dương (+)
     *    - Phạt: Số âm (-)
     *    - Có thể là 0 nếu không có thưởng/phạt
     * 
     * 4. TIỀN TĂNG CA:
     *    - Tính theo công thức: Số giờ × 50,000 VNĐ/giờ
     *    - VD: 25.5 giờ × 50,000 = 1,275,000 VNĐ
     * 
     * LƯU Ý:
     * - Tất cả tham số đều có thể là 0
     * - Kết quả có thể âm nếu tổng phạt lớn hơn tổng thu nhập
     * - Đơn vị tiền tệ: VNĐ (Việt Nam Đồng)
     */
    
    -- Hằng số: Tiền tăng ca mỗi giờ
    DECLARE @TienTangCa_MoiGio DECIMAL(18,2) = 50000;
    
    -- Tính lương thực nhận
    DECLARE @LuongThucNhan DECIMAL(18,2);
    
    SET @LuongThucNhan = ISNULL(@LuongCoBan, 0)
                       + ISNULL(@TongPhuCap, 0)
                       + ISNULL(@TongThuongPhat, 0)
                       + (ISNULL(@TongGioTangCa, 0) * @TienTangCa_MoiGio);
    
    -- Trả về kết quả
    RETURN @LuongThucNhan;
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- VÍ DỤ 1: Tính lương cơ bản (không có thưởng/phạt, không tăng ca)
SELECT dbo.fn_TinhLuongThucNhan(10000000, 2000000, 0, 0) AS N'Lương thực nhận';
-- Kết quả: 12,000,000 VNĐ

-- VÍ DỤ 2: Tính lương có thưởng và tăng ca
SELECT dbo.fn_TinhLuongThucNhan(10000000, 2000000, 500000, 25.5) AS N'Lương thực nhận';
-- Kết quả: 10,000,000 + 2,000,000 + 500,000 + (25.5 × 50,000) = 13,775,000 VNĐ

-- VÍ DỤ 3: Tính lương có phạt
SELECT dbo.fn_TinhLuongThucNhan(10000000, 2000000, -500000, 10) AS N'Lương thực nhận';
-- Kết quả: 10,000,000 + 2,000,000 - 500,000 + (10 × 50,000) = 12,000,000 VNĐ

-- VÍ DỤ 4: Sử dụng trong truy vấn để kiểm tra lương tất cả nhân viên
SELECT 
    bl.MaNV,
    nv.HoTen,
    bl.LuongCoBan,
    bl.TongPhuCap,
    bl.TongThuongPhat,
    bl.TongGioTangCa,
    dbo.fn_TinhLuongThucNhan(
        bl.LuongCoBan, 
        bl.TongPhuCap, 
        bl.TongThuongPhat, 
        bl.TongGioTangCa
    ) AS N'Lương tính bằng function',
    bl.LuongThucNhan AS N'Lương trong DB',
    -- Kiểm tra khớp không
    CASE 
        WHEN ABS(dbo.fn_TinhLuongThucNhan(bl.LuongCoBan, bl.TongPhuCap, bl.TongThuongPhat, bl.TongGioTangCa) - bl.LuongThucNhan) < 1
        THEN N'✓ Khớp'
        ELSE N'✗ Sai lệch'
    END AS N'Trạng thái'
FROM BangLuong bl
INNER JOIN NhanVien nv ON bl.MaNV = nv.MaNV
WHERE bl.Thang = 11 AND bl.Nam = 2025;

KẾT QUẢ:
- Trả về số tiền lương thực nhận (VNĐ)
- Có thể âm nếu tổng phạt quá lớn
*/

PRINT N'✓ Function fn_TinhLuongThucNhan đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6/UC7: FUNCTION KIỂM TRA CHẤM CÔNG HỢP LỆ
-- ======================================================================================
-- Tên: fn_KiemTraChamCongHopLe
-- Mục đích: Kiểm tra xem 1 bản ghi chấm công có hợp lệ hay không
-- Sử dụng: Để validate dữ liệu trước khi INSERT/UPDATE vào BangChamCong
-- Kết quả: Trả về 1 (hợp lệ) hoặc 0 (không hợp lệ)
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa function cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.fn_KiemTraChamCongHopLe', 'FN') IS NOT NULL 
    DROP FUNCTION dbo.fn_KiemTraChamCongHopLe;
GO

-- [UC6/UC7] [CHỨC NĂNG]: Kiểm tra tính hợp lệ của dữ liệu chấm công
CREATE FUNCTION fn_KiemTraChamCongHopLe(
    @MaNV_Input INT,             -- Mã nhân viên
    @Ngay_Input DATE,            -- Ngày chấm công
    @NgayCong DECIMAL(10,2),     -- Số ngày công (0.5 hoặc 1.0)
    @GioTangCa DECIMAL(10,2)     -- Số giờ tăng ca (0-12)
) 
RETURNS BIT                      -- Trả về 1 (hợp lệ) hoặc 0 (không hợp lệ)
AS
BEGIN
    /*
     * CÁC ĐIỀU KIỆN HỢP LỆ:
     * 
     * 1. NHÂN VIÊN TỒN TẠI:
     *    - MaNV phải tồn tại trong bảng NhanVien
     * 
     * 2. NGÀY HỢP LỆ:
     *    - Không được là ngày trong tương lai
     *    - Không được quá xa trong quá khứ (> 1 năm)
     * 
     * 3. NGÀY CÔNG HỢP LỆ:
     *    - Chỉ được phép: 0, 0.5, hoặc 1.0
     *    - Không được âm hoặc > 1
     * 
     * 4. GIỜ TĂNG CA HỢP LỆ:
     *    - Phải từ 0 đến 12 giờ/ngày
     *    - Không được âm
     * 
     * 5. KHÔNG TRÙNG NGÀY:
     *    - Nhân viên chưa được chấm công trong ngày đó
     *    - (Điều kiện này được kiểm tra bởi trigger riêng)
     */
    
    -- Biến kết quả
    DECLARE @HopLe BIT = 1;  -- Mặc định là hợp lệ
    
    -- ============================================================
    -- KIỂM TRA 1: NHÂN VIÊN TỒN TẠI
    -- ============================================================
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV_Input)
    BEGIN
        SET @HopLe = 0;
        RETURN @HopLe;
    END
    
    -- ============================================================
    -- KIỂM TRA 2: NGÀY HỢP LỆ
    -- ============================================================
    -- Không được là ngày trong tương lai
    IF @Ngay_Input > GETDATE()
    BEGIN
        SET @HopLe = 0;
        RETURN @HopLe;
    END
    
    -- Không được quá xa trong quá khứ (> 1 năm)
    IF @Ngay_Input < DATEADD(YEAR, -1, GETDATE())
    BEGIN
        SET @HopLe = 0;
        RETURN @HopLe;
    END
    
    -- ============================================================
    -- KIỂM TRA 3: NGÀY CÔNG HỢP LỆ
    -- ============================================================
    -- Chỉ chấp nhận: 0, 0.5, 1.0
    IF @NgayCong NOT IN (0, 0.5, 1.0)
    BEGIN
        SET @HopLe = 0;
        RETURN @HopLe;
    END
    
    -- ============================================================
    -- KIỂM TRA 4: GIỜ TĂNG CA HỢP LỆ
    -- ============================================================
    -- Phải từ 0-12 giờ
    IF @GioTangCa < 0 OR @GioTangCa > 12
    BEGIN
        SET @HopLe = 0;
        RETURN @HopLe;
    END
    
    -- ============================================================
    -- TẤT CẢ ĐIỀU KIỆN ĐỀU HỢP LỆ
    -- ============================================================
    RETURN @HopLe;
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- VÍ DỤ 1: Kiểm tra chấm công hợp lệ
SELECT dbo.fn_KiemTraChamCongHopLe(1, '2025-11-20', 1.0, 2.5) AS N'Kết quả';
-- Kết quả: 1 (hợp lệ)

-- VÍ DỤ 2: Kiểm tra ngày công không hợp lệ (1.5 không được phép)
SELECT dbo.fn_KiemTraChamCongHopLe(1, '2025-11-20', 1.5, 2.0) AS N'Kết quả';
-- Kết quả: 0 (không hợp lệ)

-- VÍ DỤ 3: Kiểm tra giờ tăng ca quá lớn
SELECT dbo.fn_KiemTraChamCongHopLe(1, '2025-11-20', 1.0, 15) AS N'Kết quả';
-- Kết quả: 0 (không hợp lệ)

-- VÍ DỤ 4: Kiểm tra nhân viên không tồn tại
SELECT dbo.fn_KiemTraChamCongHopLe(99999, '2025-11-20', 1.0, 2.0) AS N'Kết quả';
-- Kết quả: 0 (không hợp lệ)

-- VÍ DỤ 5: Sử dụng trong truy vấn để validate dữ liệu
SELECT 
    MaNV,
    Ngay,
    NgayCong,
    GioTangCa,
    CASE dbo.fn_KiemTraChamCongHopLe(MaNV, Ngay, NgayCong, GioTangCa)
        WHEN 1 THEN N'✓ Hợp lệ'
        ELSE N'✗ Không hợp lệ'
    END AS N'Trạng thái'
FROM BangChamCong
WHERE MONTH(Ngay) = 11 AND YEAR(Ngay) = 2025;

KẾT QUẢ:
- Trả về 1 nếu tất cả điều kiện đều hợp lệ
- Trả về 0 nếu có bất kỳ điều kiện nào không hợp lệ
*/

PRINT N'✓ Function fn_KiemTraChamCongHopLe đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC20: FUNCTION TÍNH TỶ LỆ ĐI LÀM
-- ======================================================================================
-- Tên: fn_TinhTyLeDiLam
-- Mục đích: Tính tỷ lệ % đi làm của nhân viên trong tháng
-- Sử dụng: Để đánh giá hiệu suất, xét thưởng, báo cáo nhân sự
-- Công thức: Tỷ lệ = (Tổng ngày công / Số ngày làm việc tiêu chuẩn) × 100%
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa function cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.fn_TinhTyLeDiLam', 'FN') IS NOT NULL 
    DROP FUNCTION dbo.fn_TinhTyLeDiLam;
GO

-- [UC20] [CHỨC NĂNG]: Tính tỷ lệ % đi làm của nhân viên
CREATE FUNCTION fn_TinhTyLeDiLam(
    @MaNV_Input INT,             -- Mã nhân viên
    @Thang_Input INT,            -- Tháng cần tính (1-12)
    @Nam_Input INT               -- Năm cần tính (VD: 2025)
) 
RETURNS DECIMAL(5,2)             -- Trả về tỷ lệ % (VD: 95.50 nghĩa là 95.50%)
AS
BEGIN
    /*
     * CÔNG THỨC TÍNH TỶ LỆ ĐI LÀM:
     * 
     * Tỷ lệ % = (Tổng ngày công thực tế / Số ngày làm việc tiêu chuẩn) × 100
     * 
     * CHI TIẾT:
     * 
     * 1. TỔNG NGÀY CÔNG THỰC TẾ:
     *    - Lấy từ bảng BangChamCong
     *    - Tính tổng cột NgayCong trong tháng
     *    - Sử dụng function fn_TinhTongNgayCong đã tạo trước đó
     * 
     * 2. SỐ NGÀY LÀM VIỆC TIÊU CHUẨN:
     *    - Mặc định: 26 ngày/tháng (trừ Chủ nhật)
     *    - Có thể điều chỉnh tùy theo chính sách công ty
     * 
     * 3. KẾT QUẢ:
     *    - 100%: Đi làm đầy đủ
     *    - 80-99%: Đi làm tốt
     *    - 60-79%: Đi làm trung bình
     *    - < 60%: Đi làm kém
     * 
     * LƯU Ý:
     * - Kết quả có thể > 100% nếu làm thêm ngày nghỉ
     * - Kết quả = 0% nếu không có chấm công
     */
    
    -- Số ngày làm việc tiêu chuẩn (26 ngày/tháng)
    DECLARE @NgayLamViec_TieuChuan DECIMAL(10,2) = 26;
    
    -- Tổng ngày công thực tế
    DECLARE @TongNgayCong DECIMAL(10,2);
    
    -- Gọi function fn_TinhTongNgayCong để lấy tổng ngày công
    SET @TongNgayCong = dbo.fn_TinhTongNgayCong(@MaNV_Input, @Thang_Input, @Nam_Input);
    
    -- Tính tỷ lệ %
    DECLARE @TyLe DECIMAL(5,2);
    
    IF @NgayLamViec_TieuChuan > 0
        SET @TyLe = (@TongNgayCong * 100.0) / @NgayLamViec_TieuChuan;
    ELSE
        SET @TyLe = 0;
    
    -- Trả về kết quả
    RETURN ISNULL(@TyLe, 0);
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- VÍ DỤ 1: Tính tỷ lệ đi làm của nhân viên mã 1 trong tháng 11/2025
SELECT dbo.fn_TinhTyLeDiLam(1, 11, 2025) AS N'Tỷ lệ đi làm (%)';
-- Kết quả: VD 95.50 (nghĩa là 95.50%)

-- VÍ DỤ 2: Xem tỷ lệ đi làm của tất cả nhân viên
SELECT 
    nv.MaNV,
    nv.HoTen,
    dbo.fn_TinhTongNgayCong(nv.MaNV, 11, 2025) AS N'Ngày công',
    CAST(dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) AS NVARCHAR(10)) + '%' AS N'Tỷ lệ đi làm',
    CASE 
        WHEN dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) >= 100 THEN N'Xuất sắc'
        WHEN dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) >= 80 THEN N'Tốt'
        WHEN dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) >= 60 THEN N'Trung bình'
        ELSE N'Kém'
    END AS N'Đánh giá'
FROM NhanVien nv
ORDER BY dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) DESC;

-- VÍ DỤ 3: Lọc nhân viên có tỷ lệ đi làm < 80%
SELECT 
    nv.MaNV,
    nv.HoTen,
    pb.TenPB,
    dbo.fn_TinhTongNgayCong(nv.MaNV, 11, 2025) AS N'Ngày công',
    CAST(dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) AS NVARCHAR(10)) + '%' AS N'Tỷ lệ đi làm'
FROM NhanVien nv
LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
WHERE dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) < 80
ORDER BY dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025) ASC;

-- VÍ DỤ 4: Thống kê theo phòng ban
SELECT 
    pb.TenPB,
    COUNT(*) AS N'Số nhân viên',
    AVG(dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025)) AS N'Tỷ lệ đi làm TB (%)'
FROM NhanVien nv
LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
GROUP BY pb.TenPB
ORDER BY AVG(dbo.fn_TinhTyLeDiLam(nv.MaNV, 11, 2025)) DESC;

KẾT QUẢ:
- Trả về tỷ lệ % (VD: 95.50)
- 100% = đi làm đầy đủ 26 ngày
- 0% = không có chấm công
*/

PRINT N'✓ Function fn_TinhTyLeDiLam đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC13: STORED PROCEDURE TÍNH BẢNG LƯƠNG THEO THÁNG
-- ======================================================================================
-- Mục đích: Tự động tính toán lương cho tất cả nhân viên trong 1 tháng cụ thể
-- Công thức: Lương thực nhận = Lương cơ bản + Phụ cấp + Thưởng/Phạt + (Giờ tăng ca × 50,000)
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa stored procedure cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.sp_TinhBangLuong_Thang', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_TinhBangLuong_Thang;
GO

-- [UC13] [CHỨC NĂNG]: Tính toán bảng lương tháng (xóa cũ, tính mới dựa trên các hàm con)
CREATE PROCEDURE sp_TinhBangLuong_Thang 
    @Thang_BangLuong INT,        -- Tháng cần tính lương (1-12)
    @Nam_BangLuong INT           -- Năm cần tính lương (VD: 2025)
AS
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * QUY TRÌNH TÍNH LƯƠNG:
     * 
     * BƯỚC 1: XÓA DỮ LIỆU CŨ
     * - Xóa tất cả bản ghi lương của tháng/năm được chỉ định
     * - Mục đích: Tránh trùng lặp khi tính lại lương
     * 
     * BƯỚC 2: TÍNH LƯƠNG MỚI
     * - Lấy danh sách tất cả nhân viên
     * - Tính từng thành phần lương:
     *   + Lương cơ bản: Ưu tiên từ Hợp đồng, nếu không có thì lấy từ Chức vụ
     *   + Tổng phụ cấp: SUM từ bảng PhuCap
     *   + Tổng thưởng/phạt: SUM từ bảng ThuongPhat (Thưởng = +, Phạt = -)
     *   + Tổng giờ tăng ca: Gọi function fn_TongGioTangCa_Thang
     * 
     * BƯỚC 3: LƯU KẾT QUẢ
     * - INSERT vào bảng BangLuong
     * - Cột LuongThucNhan được tính tự động bởi Computed Column trong DB
     */
    
    -- ============================================================
    -- BƯỚC 1: XÓA DỮ LIỆU LƯƠNG CŨ (NẾU ĐÃ TÍNH TRƯỚC ĐÓ)
    -- ============================================================
    DELETE FROM BangLuong 
    WHERE Thang = @Thang_BangLuong 
      AND Nam = @Nam_BangLuong;
    
    PRINT N'→ Đã xóa dữ liệu lương cũ (nếu có) của tháng ' + CAST(@Thang_BangLuong AS NVARCHAR(2)) + '/' + CAST(@Nam_BangLuong AS NVARCHAR(4));
    
    -- ============================================================
    -- BƯỚC 2: TÍNH LƯƠNG MỚI CHO TẤT CẢ NHÂN VIÊN
    -- ============================================================
    INSERT INTO BangLuong (
        MaNV,                    -- Mã nhân viên
        Thang,                   -- Tháng tính lương
        Nam,                     -- Năm tính lương
        LuongCoBan,              -- Lương cơ bản
        TongPhuCap,              -- Tổng phụ cấp
        TongThuongPhat,          -- Tổng thưởng/phạt
        TongGioTangCa            -- Tổng giờ tăng ca
    )
    SELECT 
        nv.MaNV,
        @Thang_BangLuong,
        @Nam_BangLuong,
        
        -- TÍNH LƯƠNG CƠ BẢN:
        -- Ưu tiên lấy từ Hợp đồng mới nhất, nếu không có thì lấy từ Chức vụ
        ISNULL(hd.LuongCoBan, ISNULL(lcb.MucLuong, 0)) AS LuongCoBan_NhanVien,
        
        -- TÍNH TỔNG PHỤ CẤP:
        -- SUM tất cả phụ cấp của nhân viên (xăng xe, điện thoại, ăn trưa, v.v.)
        ISNULL((
            SELECT SUM(SoTien) 
            FROM PhuCap pc 
            WHERE pc.MaNV = nv.MaNV
        ), 0) AS TongPhuCap_NhanVien,
        
        -- TÍNH TỔNG THƯỞNG/PHẠT:
        -- Thưởng = cộng (+), Phạt = trừ (-)
        ISNULL((
            SELECT SUM(
                CASE 
                    WHEN tp.Loai = N'Thưởng' THEN tp.SoTien 
                    WHEN tp.Loai = N'Phạt' THEN -tp.SoTien 
                END
            ) 
            FROM ThuongPhat tp 
            WHERE tp.MaNV = nv.MaNV
        ), 0) AS TongThuongPhat_NhanVien,
        
        -- TÍNH TỔNG GIỜ TĂNG CA:
        -- Gọi function fn_TongGioTangCa_Thang để tính tổng giờ làm thêm trong tháng
        ISNULL((
            SELECT SUM(cc.GioTangCa) 
            FROM BangChamCong cc 
            WHERE cc.MaNV = nv.MaNV 
              AND MONTH(cc.Ngay) = @Thang_BangLuong 
              AND YEAR(cc.Ngay) = @Nam_BangLuong
        ), 0) AS TongGioTangCa_NhanVien
        
    FROM NhanVien nv
    
    -- JOIN với Hợp đồng để lấy lương cơ bản (nếu có)
    LEFT JOIN HopDong hd 
        ON nv.MaNV = hd.MaNV
    
    -- JOIN với Lương cơ bản theo Chức vụ (fallback nếu không có hợp đồng)
    LEFT JOIN LuongCoban lcb 
        ON nv.MaCV = lcb.MaCV
    
    -- GROUP BY để tránh trùng lặp khi nhân viên có nhiều hợp đồng
    GROUP BY 
        nv.MaNV, 
        hd.LuongCoBan, 
        lcb.MucLuong;
    
    -- ============================================================
    -- BƯỚC 3: THÔNG BÁO KẾT QUẢ
    -- ============================================================
    DECLARE @SoNhanVien_DaTinhLuong INT;
    SELECT @SoNhanVien_DaTinhLuong = COUNT(*) 
    FROM BangLuong 
    WHERE Thang = @Thang_BangLuong 
      AND Nam = @Nam_BangLuong;
    
    PRINT N'✓ Đã tính lương thành công cho ' + CAST(@SoNhanVien_DaTinhLuong AS NVARCHAR(10)) + N' nhân viên!';
    PRINT N'→ Tháng: ' + CAST(@Thang_BangLuong AS NVARCHAR(2)) + '/' + CAST(@Nam_BangLuong AS NVARCHAR(4));
END;
GO

PRINT N'✓ Stored Procedure sp_TinhBangLuong_Thang đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6: STORED PROCEDURE XÓA DỮ LIỆU CHẤM CÔNG THEO THÁNG
-- ======================================================================================
-- Tên: sp_XoaChamCongTheoThang
-- Mục đích: Xóa toàn bộ dữ liệu chấm công của 1 tháng cụ thể (để tính lại hoặc sửa lỗi)
-- Sử dụng: Khi cần làm sạch dữ liệu chấm công sai hoặc chuẩn bị nhập lại
-- Lưu ý: Thao tác này không thể hoàn tác, cần cẩn thận khi sử dụng
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa stored procedure cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.sp_XoaChamCongTheoThang', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_XoaChamCongTheoThang;
GO

-- [UC6] [CHỨC NĂNG]: Xóa dữ liệu chấm công theo tháng/năm
CREATE PROCEDURE sp_XoaChamCongTheoThang
    @Thang_Input INT,            -- Tháng cần xóa (1-12)
    @Nam_Input INT,              -- Năm cần xóa (VD: 2025)
    @XacNhan NVARCHAR(10) = NULL -- Chuỗi xác nhận 'XAC_NHAN' để tránh xóa nhầm
AS
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * QUY TRÌNH XÓA DỮ LIỆU:
     * 
     * BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
     * - Kiểm tra tháng hợp lệ (1-12)
     * - Kiểm tra năm hợp lệ
     * - Kiểm tra chuỗi xác nhận để tránh xóa nhầm
     * 
     * BƯỚC 2: ĐẾM SỐ LƯỢNG BẢN GHI SẼ BỊ XÓA
     * - Thông báo cho người dùng biết số lượng bản ghi sẽ bị xóa
     * - Cho phép kiểm tra trước khi thực hiện
     * 
     * BƯỚC 3: THỰC HIỆN XÓA
     * - Xóa tất cả bản ghi chấm công trong tháng/năm chỉ định
     * - Thông báo kết quả
     */
    
    -- ============================================================
    -- BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
    -- ============================================================
    
    -- Kiểm tra tháng hợp lệ
    IF @Thang_Input < 1 OR @Thang_Input > 12
    BEGIN
        RAISERROR(N'Lỗi: Tháng không hợp lệ. Vui lòng nhập từ 1-12', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra năm hợp lệ
    IF @Nam_Input < 2000 OR @Nam_Input > YEAR(GETDATE()) + 1
    BEGIN
        RAISERROR(N'Lỗi: Năm không hợp lệ', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra chuỗi xác nhận (bảo vệ chống xóa nhầm)
    IF @XacNhan IS NULL OR @XacNhan <> 'XAC_NHAN'
    BEGIN
        RAISERROR(N'Lỗi: Vui lòng truyền tham số @XacNhan = ''XAC_NHAN'' để xác nhận xóa dữ liệu', 16, 1);
        PRINT N'→ Cách sử dụng: EXEC sp_XoaChamCongTheoThang @Thang_Input = 11, @Nam_Input = 2025, @XacNhan = ''XAC_NHAN''';
        RETURN;
    END
    
    -- ============================================================
    -- BƯỚC 2: ĐẾM SỐ LƯỢNG BẢN GHI SẼ BỊ XÓA
    -- ============================================================
    
    DECLARE @SoLuongBanGhi INT;
    
    SELECT @SoLuongBanGhi = COUNT(*)
    FROM BangChamCong
    WHERE MONTH(Ngay) = @Thang_Input
      AND YEAR(Ngay) = @Nam_Input;
    
    -- Nếu không có dữ liệu, thông báo và thoát
    IF @SoLuongBanGhi = 0
    BEGIN
        PRINT N'⚠ Không có dữ liệu chấm công nào trong tháng ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
        RETURN;
    END
    
    PRINT N'⚠ CẢNH BÁO: Sắp xóa ' + CAST(@SoLuongBanGhi AS NVARCHAR(10)) + N' bản ghi chấm công!';
    PRINT N'→ Tháng/Năm: ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
    
    -- ============================================================
    -- BƯỚC 3: THỰC HIỆN XÓA DỮ LIỆU
    -- ============================================================
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM BangChamCong
        WHERE MONTH(Ngay) = @Thang_Input
          AND YEAR(Ngay) = @Nam_Input;
        
        COMMIT TRANSACTION;
        
        PRINT N'✓ Đã xóa thành công ' + CAST(@SoLuongBanGhi AS NVARCHAR(10)) + N' bản ghi chấm công!';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Lỗi khi xóa dữ liệu: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- Xóa tất cả dữ liệu chấm công tháng 11/2025
EXEC sp_XoaChamCongTheoThang 
    @Thang_Input = 11,
    @Nam_Input = 2025,
    @XacNhan = 'XAC_NHAN';

-- Nếu quên tham số @XacNhan, sẽ báo lỗi và hướng dẫn
EXEC sp_XoaChamCongTheoThang 
    @Thang_Input = 11,
    @Nam_Input = 2025;
-- Kết quả: Lỗi yêu cầu xác nhận

LƯU Ý:
- Thao tác này KHÔNG THỂ HOÀN TÁC
- Chỉ sử dụng khi thực sự cần thiết
- Nên backup dữ liệu trước khi xóa
*/

PRINT N'✓ Stored Procedure sp_XoaChamCongTheoThang đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6/UC8: STORED PROCEDURE CẬP NHẬT GIỜ TĂNG CA
-- ======================================================================================
-- Tên: sp_CapNhatGioTangCa
-- Mục đích: Cập nhật số giờ tăng ca cho 1 bản ghi chấm công cụ thể
-- Sử dụng: Khi cần sửa lại giờ tăng ca đã nhập sai hoặc bổ sung thêm
-- Lưu ý: Tự động kiểm tra giá trị hợp lệ (0-12 giờ/ngày)
-- ======================================================================================

USE QL_LuongNV;
GO

---- Xóa stored procedure cũ nếu tồn tại để tạo lại
--IF OBJECT_ID('dbo.sp_CapNhatGioTangCa', 'P') IS NOT NULL 
--    DROP PROCEDURE dbo.sp_CapNhatGioTangCa;
--GO

---- [UC6/UC8] [CHỨC NĂNG]: Cập nhật giờ tăng ca cho bản ghi chấm công
--CREATE PROCEDURE sp_CapNhatGioTangCa
--    @MaNV_Input INT,             -- Mã nhân viên
--    @Ngay_Input DATE,            -- Ngày chấm công cần cập nhật
--    @GioTangCa_Moi DECIMAL(10,2) -- Số giờ tăng ca mới
--AS
--BEGIN
--    -- Tắt thông báo số dòng bị ảnh hưởng
--    SET NOCOUNT ON;
    
--    /*
--     * QUY TRÌNH CẬP NHẬT:
--     * 
--     * BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
--     * - Kiểm tra nhân viên có tồn tại không
--     * - Kiểm tra bản ghi chấm công có tồn tại không
--     * - Kiểm tra giờ tăng ca hợp lệ (0-12 giờ)
--     * 
--     * BƯỚC 2: CẬP NHẬT GIỜ TĂNG CA
--     * - Lưu giá trị cũ để so sánh
--     * - Cập nhật giá trị mới
--     * - Thông báo kết quả
--     * 
--     * BƯỚC 3: TỰ ĐỘNG CẬP NHẬT BẢNG LƯƠNG (NẾU CẦN)
--     * - Nếu đã có bảng lương của tháng đó, cần tính lại
--     */
    
--    -- ============================================================
--    -- BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
--    -- ============================================================
    
--    -- Kiểm tra nhân viên có tồn tại không
--    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV_Input)
--    BEGIN
--        RAISERROR(N'Lỗi: Không tìm thấy nhân viên với mã %d', 16, 1, @MaNV_Input);
--        RETURN;
--    END
    
--    -- Kiểm tra bản ghi chấm công có tồn tại không
--    IF NOT EXISTS (
--        SELECT 1 FROM BangChamCong 
--        WHERE MaNV = @MaNV_Input AND Ngay = @Ngay_Input
--    )
--    BEGIN
--        RAISERROR(N'Lỗi: Không tìm thấy bản ghi chấm công cho nhân viên %d vào ngày %s', 
--                  16, 1, @MaNV_Input, CONVERT(NVARCHAR(10), @Ngay_Input, 103));
--        RETURN;
--    END
    
--    -- Kiểm tra giờ tăng ca hợp lệ (0-12 giờ/ngày)
--    IF @GioTangCa_Moi < 0 OR @GioTangCa_Moi > 12
--    BEGIN
--        RAISERROR(N'Lỗi: Giờ tăng ca không hợp lệ. Vui lòng nhập từ 0-12 giờ', 16, 1);
--        RETURN;
--    END
    
    -- ============================================================
    -- BƯỚC 2: CẬP NHẬT GIỜ TĂNG CA
    -- ============================================================
    
    -- Lưu giá trị cũ để thông báo
    DECLARE @GioTangCa_Cu DECIMAL(10,2);
    
    SELECT @GioTangCa_Cu = GioTangCa
    FROM BangChamCong
    WHERE MaNV = @MaNV_Input AND Ngay = @Ngay_Input;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Cập nhật giờ tăng ca mới
        UPDATE BangChamCong
        SET GioTangCa = @GioTangCa_Moi
        WHERE MaNV = @MaNV_Input AND Ngay = @Ngay_Input;
        
        COMMIT TRANSACTION;
        
        -- Thông báo kết quả
        DECLARE @TenNV NVARCHAR(100);
        SELECT @TenNV = HoTen FROM NhanVien WHERE MaNV = @MaNV_Input;
        
        PRINT N'✓ Cập nhật giờ tăng ca thành công!';
        PRINT N'→ Nhân viên: ' + @TenNV + N' (Mã: ' + CAST(@MaNV_Input AS NVARCHAR(10)) + ')';
        PRINT N'→ Ngày: ' + CONVERT(NVARCHAR(10), @Ngay_Input, 103);
        PRINT N'→ Giờ tăng ca cũ: ' + CAST(@GioTangCa_Cu AS NVARCHAR(10)) + N' giờ';
        PRINT N'→ Giờ tăng ca mới: ' + CAST(@GioTangCa_Moi AS NVARCHAR(10)) + N' giờ';
        PRINT N'→ Chênh lệch: ' + CAST((@GioTangCa_Moi - @GioTangCa_Cu) AS NVARCHAR(10)) + N' giờ';
        
        -- ============================================================
        -- BƯỚC 3: THÔNG BÁO CẦN TÍNH LẠI LƯƠNG (NẾU CẦN)
        -- ============================================================
        
        DECLARE @Thang INT = MONTH(@Ngay_Input);
        DECLARE @Nam INT = YEAR(@Ngay_Input);
        
        IF EXISTS (
            SELECT 1 FROM BangLuong 
            WHERE MaNV = @MaNV_Input AND Thang = @Thang AND Nam = @Nam
        )
        BEGIN
            PRINT N'';
            PRINT N'⚠ LƯU Ý: Bảng lương tháng ' + CAST(@Thang AS NVARCHAR(2)) + '/' + CAST(@Nam AS NVARCHAR(4)) + N' đã tồn tại.';
            PRINT N'→ Vui lòng chạy lại sp_TinhBangLuong_Thang để cập nhật lương mới!';
        END
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Lỗi khi cập nhật giờ tăng ca: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- Cập nhật giờ tăng ca cho nhân viên mã 1 vào ngày 20/11/2025 thành 3.5 giờ
EXEC sp_CapNhatGioTangCa 
    @MaNV_Input = 1,
    @Ngay_Input = '2025-11-20',
    @GioTangCa_Moi = 3.5;

-- Nếu muốn xóa giờ tăng ca (đặt về 0)
EXEC sp_CapNhatGioTangCa 
    @MaNV_Input = 1,
    @Ngay_Input = '2025-11-20',
    @GioTangCa_Moi = 0;

LƯU Ý:
- Giờ tăng ca phải từ 0-12 giờ/ngày
- Nếu đã tính lương tháng đó, cần chạy lại sp_TinhBangLuong_Thang
*/

PRINT N'✓ Stored Procedure sp_CapNhatGioTangCa đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC20: STORED PROCEDURE THỐNG KÊ LƯƠNG THEO THÁNG
-- ======================================================================================
-- Tên: sp_ThongKeLuongTheoThang
-- Mục đích: Lấy thống kê tổng hợp lương của tất cả nhân viên trong 1 tháng
-- Sử dụng: Để xem báo cáo lương, phân tích chi phí nhân sự
-- Kết quả: Trả về danh sách nhân viên với thông tin lương chi tiết
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa stored procedure cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.sp_ThongKeLuongTheoThang', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_ThongKeLuongTheoThang;
GO

-- [UC20] [CHỨC NĂNG]: Thống kê và báo cáo lương theo tháng
CREATE PROCEDURE sp_ThongKeLuongTheoThang
    @Thang_Input INT,            -- Tháng cần thống kê (1-12)
    @Nam_Input INT               -- Năm cần thống kê (VD: 2025)
AS
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * QUY TRÌNH THỐNG KÊ:
     * 
     * BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
     * - Kiểm tra tháng hợp lệ (1-12)
     * - Kiểm tra năm hợp lệ
     * - Kiểm tra có dữ liệu lương không
     * 
     * BƯỚC 2: LẤY THỐNG KÊ CHI TIẾT
     * - Thông tin nhân viên (Mã, Tên, Phòng ban, Chức vụ)
     * - Các thành phần lương (Cơ bản, Phụ cấp, Thưởng/Phạt, Tăng ca)
     * - Lương thực nhận
     * - Sắp xếp theo lương giảm dần
     * 
     * BƯỚC 3: TÍNH TỔNG HỢP
     * - Tổng lương phải trả
     * - Số lượng nhân viên
     * - Lương trung bình
     */
    
    -- ============================================================
    -- BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
    -- ============================================================
    
    -- Kiểm tra tháng hợp lệ
    IF @Thang_Input < 1 OR @Thang_Input > 12
    BEGIN
        RAISERROR(N'Lỗi: Tháng không hợp lệ. Vui lòng nhập từ 1-12', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra năm hợp lệ
    IF @Nam_Input < 2000 OR @Nam_Input > YEAR(GETDATE()) + 1
    BEGIN
        RAISERROR(N'Lỗi: Năm không hợp lệ', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra có dữ liệu lương không
    IF NOT EXISTS (
        SELECT 1 FROM BangLuong 
        WHERE Thang = @Thang_Input AND Nam = @Nam_Input
    )
    BEGIN
        PRINT N'⚠ Chưa có dữ liệu lương cho tháng ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
        PRINT N'→ Vui lòng chạy sp_TinhBangLuong_Thang trước!';
        RETURN;
    END
    
    -- ============================================================
    -- BƯỚC 2: LẤY THỐNG KÊ CHI TIẾT
    -- ============================================================
    
    PRINT N'';
    PRINT N'═══════════════════════════════════════════════════════════════════════════════';
    PRINT N'                    BÁO CÁO LƯƠNG THÁNG ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
    PRINT N'═══════════════════════════════════════════════════════════════════════════════';
    PRINT N'';
    
    -- Truy vấn chi tiết lương từng nhân viên
    SELECT 
        bl.MaNV AS N'Mã NV',
        nv.HoTen AS N'Họ tên',
        pb.TenPB AS N'Phòng ban',
        cv.TenCV AS N'Chức vụ',
        FORMAT(bl.LuongCoBan, 'N0') AS N'Lương cơ bản',
        FORMAT(bl.TongPhuCap, 'N0') AS N'Phụ cấp',
        FORMAT(bl.TongThuongPhat, 'N0') AS N'Thưởng/Phạt',
        CAST(bl.TongGioTangCa AS NVARCHAR(10)) AS N'Giờ tăng ca',
        FORMAT(bl.TongGioTangCa * 50000, 'N0') AS N'Tiền tăng ca',
        FORMAT(bl.LuongThucNhan, 'N0') AS N'Lương thực nhận'
    FROM BangLuong bl
    INNER JOIN NhanVien nv ON bl.MaNV = nv.MaNV
    LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
    LEFT JOIN ChucVu cv ON nv.MaCV = cv.MaCV
    WHERE bl.Thang = @Thang_Input 
      AND bl.Nam = @Nam_Input
    ORDER BY bl.LuongThucNhan DESC;
    
    -- ============================================================
    -- BƯỚC 3: TÍNH TỔNG HỢP
    -- ============================================================
    
    DECLARE @TongLuong DECIMAL(18,2);
    DECLARE @SoNhanVien INT;
    DECLARE @LuongTrungBinh DECIMAL(18,2);
    
    SELECT 
        @TongLuong = SUM(LuongThucNhan),
        @SoNhanVien = COUNT(*),
        @LuongTrungBinh = AVG(LuongThucNhan)
    FROM BangLuong
    WHERE Thang = @Thang_Input AND Nam = @Nam_Input;
    
    PRINT N'';
    PRINT N'───────────────────────────────────────────────────────────────────────────────';
    PRINT N'TỔNG HỢP:';
    PRINT N'→ Số lượng nhân viên: ' + CAST(@SoNhanVien AS NVARCHAR(10)) + N' người';
    PRINT N'→ Tổng lương phải trả: ' + FORMAT(@TongLuong, 'N0') + N' VNĐ';
    PRINT N'→ Lương trung bình: ' + FORMAT(@LuongTrungBinh, 'N0') + N' VNĐ';
    PRINT N'═══════════════════════════════════════════════════════════════════════════════';
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- Xem thống kê lương tháng 11/2025
EXEC sp_ThongKeLuongTheoThang 
    @Thang_Input = 11,
    @Nam_Input = 2025;

-- Xem thống kê lương tháng hiện tại
EXEC sp_ThongKeLuongTheoThang 
    @Thang_Input = MONTH(GETDATE()),
    @Nam_Input = YEAR(GETDATE());

KẾT QUẢ TRẢ VỀ:
- Bảng chi tiết: Danh sách nhân viên với các thành phần lương
- Thống kê tổng hợp: Tổng lương, số nhân viên, lương trung bình
*/

PRINT N'✓ Stored Procedure sp_ThongKeLuongTheoThang đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC20: STORED PROCEDURE XUẤT BÁO CÁO LƯƠNG CHI TIẾT
-- ======================================================================================
-- Tên: sp_XuatBaoCaoLuong
-- Mục đích: Xuất báo cáo lương chi tiết cho 1 nhân viên hoặc toàn bộ công ty
-- Sử dụng: Để in phiếu lương, gửi email thông báo lương cho nhân viên
-- Kết quả: Trả về thông tin lương đầy đủ kèm phân tích các thành phần
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa stored procedure cũ nếu tồn tại để tạo lại
IF OBJECT_ID('dbo.sp_XuatBaoCaoLuong', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_XuatBaoCaoLuong;
GO

-- [UC20] [CHỨC NĂNG]: Xuất báo cáo lương chi tiết theo nhân viên
CREATE PROCEDURE sp_XuatBaoCaoLuong
    @MaNV_Input INT = NULL,      -- Mã nhân viên (NULL = tất cả nhân viên)
    @Thang_Input INT,            -- Tháng cần xuất báo cáo (1-12)
    @Nam_Input INT               -- Năm cần xuất báo cáo (VD: 2025)
AS
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * QUY TRÌNH XUẤT BÁO CÁO:
     * 
     * BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
     * - Kiểm tra tháng/năm hợp lệ
     * - Kiểm tra nhân viên có tồn tại (nếu chỉ định)
     * - Kiểm tra có dữ liệu lương không
     * 
     * BƯỚC 2: XUẤT BÁO CÁO CHI TIẾT
     * - Nếu @MaNV_Input = NULL: Xuất tất cả nhân viên
     * - Nếu @MaNV_Input có giá trị: Chỉ xuất 1 nhân viên
     * - Bao gồm: Thông tin cá nhân, các thành phần lương, tổng cộng
     * 
     * BƯỚC 3: PHÂN TÍCH BỔ SUNG
     * - Tỷ lệ % từng thành phần lương
     * - So sánh với lương trung bình công ty
     */
    
    -- ============================================================
    -- BƯỚC 1: KIỂM TRA THAM SỐ ĐẦU VÀO
    -- ============================================================
    
    -- Kiểm tra tháng hợp lệ
    IF @Thang_Input < 1 OR @Thang_Input > 12
    BEGIN
        RAISERROR(N'Lỗi: Tháng không hợp lệ. Vui lòng nhập từ 1-12', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra năm hợp lệ
    IF @Nam_Input < 2000 OR @Nam_Input > YEAR(GETDATE()) + 1
    BEGIN
        RAISERROR(N'Lỗi: Năm không hợp lệ', 16, 1);
        RETURN;
    END
    
    -- Kiểm tra nhân viên có tồn tại (nếu chỉ định)
    IF @MaNV_Input IS NOT NULL AND NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV_Input)
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy nhân viên với mã %d', 16, 1, @MaNV_Input);
        RETURN;
    END
    
    -- Kiểm tra có dữ liệu lương không
    IF NOT EXISTS (
        SELECT 1 FROM BangLuong 
        WHERE Thang = @Thang_Input 
          AND Nam = @Nam_Input
          AND (@MaNV_Input IS NULL OR MaNV = @MaNV_Input)
    )
    BEGIN
        PRINT N'⚠ Không có dữ liệu lương cho tháng ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
        IF @MaNV_Input IS NOT NULL
            PRINT N'→ Nhân viên mã: ' + CAST(@MaNV_Input AS NVARCHAR(10));
        RETURN;
    END
    
    -- ============================================================
    -- BƯỚC 2: XUẤT BÁO CÁO CHI TIẾT
    -- ============================================================
    
    PRINT N'';
    PRINT N'═══════════════════════════════════════════════════════════════════════════════';
    PRINT N'                    PHIẾU LƯƠNG THÁNG ' + CAST(@Thang_Input AS NVARCHAR(2)) + '/' + CAST(@Nam_Input AS NVARCHAR(4));
    PRINT N'═══════════════════════════════════════════════════════════════════════════════';
    PRINT N'';
    
    -- Truy vấn chi tiết lương
    SELECT 
        -- THÔNG TIN NHÂN VIÊN
        bl.MaNV AS N'Mã NV',
        nv.HoTen AS N'Họ và tên',
        nv.GioiTinh AS N'Giới tính',
        nv.NgaySinh AS N'Ngày sinh',
        pb.TenPB AS N'Phòng ban',
        cv.TenCV AS N'Chức vụ',
        
        -- CÁC THÀNH PHẦN LƯƠNG
        FORMAT(bl.LuongCoBan, 'N0') + N' VNĐ' AS N'1. Lương cơ bản',
        FORMAT(bl.TongPhuCap, 'N0') + N' VNĐ' AS N'2. Tổng phụ cấp',
        FORMAT(bl.TongThuongPhat, 'N0') + N' VNĐ' AS N'3. Thưởng/Phạt',
        
        -- TĂNG CA
        CAST(bl.TongGioTangCa AS NVARCHAR(10)) + N' giờ' AS N'4a. Số giờ tăng ca',
        FORMAT(bl.TongGioTangCa * 50000, 'N0') + N' VNĐ' AS N'4b. Tiền tăng ca',
        
        -- TỔNG CỘNG
        FORMAT(bl.LuongThucNhan, 'N0') + N' VNĐ' AS N'TỔNG LƯƠNG THỰC NHẬN',
        
        -- PHÂN TÍCH TỶ LỆ
        CAST(ROUND((bl.LuongCoBan * 100.0 / NULLIF(bl.LuongThucNhan, 0)), 2) AS NVARCHAR(10)) + '%' AS N'% Lương cơ bản',
        CAST(ROUND((bl.TongPhuCap * 100.0 / NULLIF(bl.LuongThucNhan, 0)), 2) AS NVARCHAR(10)) + '%' AS N'% Phụ cấp',
        CAST(ROUND(((bl.TongGioTangCa * 50000) * 100.0 / NULLIF(bl.LuongThucNhan, 0)), 2) AS NVARCHAR(10)) + '%' AS N'% Tăng ca'
        
    FROM BangLuong bl
    INNER JOIN NhanVien nv ON bl.MaNV = nv.MaNV
    LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
    LEFT JOIN ChucVu cv ON nv.MaCV = cv.MaCV
    WHERE bl.Thang = @Thang_Input 
      AND bl.Nam = @Nam_Input
      AND (@MaNV_Input IS NULL OR bl.MaNV = @MaNV_Input)
    ORDER BY bl.MaNV;
    
    -- ============================================================
    -- BƯỚC 3: THỐNG KÊ BỔ SUNG (CHỈ KHI XEM 1 NHÂN VIÊN)
    -- ============================================================
    
    IF @MaNV_Input IS NOT NULL
    BEGIN
        DECLARE @LuongNV DECIMAL(18,2);
        DECLARE @LuongTrungBinh DECIMAL(18,2);
        
        -- Lấy lương của nhân viên
        SELECT @LuongNV = LuongThucNhan
        FROM BangLuong
        WHERE MaNV = @MaNV_Input 
          AND Thang = @Thang_Input 
          AND Nam = @Nam_Input;
        
        -- Lấy lương trung bình công ty
        SELECT @LuongTrungBinh = AVG(LuongThucNhan)
        FROM BangLuong
        WHERE Thang = @Thang_Input AND Nam = @Nam_Input;
        
        PRINT N'';
        PRINT N'───────────────────────────────────────────────────────────────────────────────';
        PRINT N'SO SÁNH VỚI LƯƠNG TRUNG BÌNH CÔNG TY:';
        PRINT N'→ Lương nhân viên: ' + FORMAT(@LuongNV, 'N0') + N' VNĐ';
        PRINT N'→ Lương trung bình: ' + FORMAT(@LuongTrungBinh, 'N0') + N' VNĐ';
        
        IF @LuongNV > @LuongTrungBinh
            PRINT N'→ Cao hơn trung bình: +' + FORMAT(@LuongNV - @LuongTrungBinh, 'N0') + N' VNĐ';
        ELSE
            PRINT N'→ Thấp hơn trung bình: -' + FORMAT(@LuongTrungBinh - @LuongNV, 'N0') + N' VNĐ';
        
        PRINT N'═══════════════════════════════════════════════════════════════════════════════';
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
VÍ DỤ SỬ DỤNG:

-- Xuất báo cáo lương cho 1 nhân viên cụ thể
EXEC sp_XuatBaoCaoLuong 
    @MaNV_Input = 1,
    @Thang_Input = 11,
    @Nam_Input = 2025;

-- Xuất báo cáo lương cho TẤT CẢ nhân viên
EXEC sp_XuatBaoCaoLuong 
    @MaNV_Input = NULL,
    @Thang_Input = 11,
    @Nam_Input = 2025;

KẾT QUẢ:
- Thông tin nhân viên đầy đủ
- Phân tích các thành phần lương
- Tỷ lệ % từng thành phần
- So sánh với lương trung bình (nếu xem 1 nhân viên)
*/

PRINT N'✓ Stored Procedure sp_XuatBaoCaoLuong đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC7: TRIGGER NGĂN CHẶN CHẤM CÔNG TRÙNG NGÀY
-- ======================================================================================
-- Mục đích: Đảm bảo mỗi nhân viên chỉ được chấm công 1 lần trong 1 ngày
-- Trigger này sẽ tự động kiểm tra khi INSERT vào bảng BangChamCong
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa trigger cũ nếu tồn tại để tạo lại
IF OBJECT_ID('trg_PreventDuplicate_ChanCong', 'TR') IS NOT NULL 
    DROP TRIGGER trg_PreventDuplicate_ChanCong;
GO

-- [UC7] [CHỨC NĂNG]: Ngăn chặn chấm công trùng ngày cho cùng 1 nhân viên
CREATE TRIGGER trg_PreventDuplicate_ChanCong 
ON BangChamCong 
AFTER INSERT 
AS 
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng để tăng hiệu suất
    SET NOCOUNT ON;
    
    /*
     * LOGIC KIỂM TRA:
     * 1. JOIN bảng BangChamCong với bảng inserted (dữ liệu mới được thêm vào)
     * 2. Kiểm tra điều kiện trùng: cùng MaNV (mã nhân viên) VÀ cùng Ngay (ngày chấm công)
     * 3. GROUP BY theo MaNV và Ngay
     * 4. Nếu COUNT(*) > 1 nghĩa là có nhiều hơn 1 bản ghi cùng nhân viên cùng ngày
     * 5. RAISERROR để báo lỗi và ROLLBACK TRANSACTION để hủy thao tác INSERT
     */
    
    -- Biến kiểm tra: Đếm số bản ghi trùng
    DECLARE @SoLuongTrung_BangChamCong INT;
    
    -- Kiểm tra xem có bản ghi nào bị trùng không
    SELECT @SoLuongTrung_BangChamCong = COUNT(*)
    FROM BangChamCong c
    INNER JOIN inserted i 
        ON c.MaNV = i.MaNV           -- Cùng mã nhân viên
        AND c.Ngay = i.Ngay          -- Cùng ngày chấm công
    GROUP BY c.MaNV, c.Ngay
    HAVING COUNT(*) > 1;             -- Có nhiều hơn 1 bản ghi
    
    -- Nếu phát hiện trùng, báo lỗi và hủy giao dịch
    IF @SoLuongTrung_BangChamCong > 0
    BEGIN
        -- Thông báo lỗi với mức độ nghiêm trọng 16 (lỗi người dùng)
        RAISERROR(N'Chấm công trùng ngày! Nhân viên này đã được chấm công trong ngày hôm nay.', 16, 1);
        
        -- Hủy toàn bộ giao dịch INSERT
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
CÁCH HOẠT ĐỘNG:
- Trigger này tự động chạy SAU KHI (AFTER) có lệnh INSERT vào bảng BangChamCong
- Không cần gọi thủ công, SQL Server sẽ tự động kích hoạt

VÍ DỤ TEST:

-- Test 1: Chấm công bình thường (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-20', 1.0, 2.5);

-- Test 2: Chấm công trùng ngày (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-20', 0.5, 1.0);
-- Kết quả: Lỗi "Chấm công trùng ngày!"

-- Test 3: Chấm công khác ngày (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-21', 1.0, 3.0);

KIỂM TRA TRIGGER ĐÃ TỒN TẠI:
SELECT * FROM sys.triggers WHERE name = 'trg_PreventDuplicate_ChanCong';
*/

PRINT N'✓ Trigger trg_PreventDuplicate_ChanCong đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6/UC8: TRIGGER VALIDATE GIỜ TĂNG CA
-- ======================================================================================
-- Tên: trg_ValidateGioTangCa
-- Mục đích: Tự động kiểm tra giờ tăng ca hợp lệ khi INSERT/UPDATE vào BangChamCong
-- Điều kiện: Giờ tăng ca phải từ 0-12 giờ/ngày
-- Hành động: Chặn và báo lỗi nếu giờ tăng ca không hợp lệ
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa trigger cũ nếu tồn tại để tạo lại
IF OBJECT_ID('trg_ValidateGioTangCa', 'TR') IS NOT NULL 
    DROP TRIGGER trg_ValidateGioTangCa;
GO

-- [UC6/UC8] [CHỨC NĂNG]: Validate giờ tăng ca hợp lệ (0-12 giờ)
CREATE TRIGGER trg_ValidateGioTangCa 
ON BangChamCong 
AFTER INSERT, UPDATE
AS 
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * LOGIC KIỂM TRA:
     * 
     * 1. Kiểm tra giờ tăng ca không được âm (< 0)
     * 2. Kiểm tra giờ tăng ca không được quá 12 giờ/ngày
     * 3. Nếu vi phạm: RAISERROR và ROLLBACK TRANSACTION
     * 
     * LÝ DO GIỚI HẠN 12 GIỜ:
     * - 1 ngày làm việc tiêu chuẩn: 8 giờ
     * - Tăng ca tối đa hợp lý: 4 giờ
     * - Tổng cộng: 12 giờ/ngày
     * - Nếu > 12 giờ có thể là lỗi nhập liệu
     * 
     * THỜI ĐIỂM KÍCH HOẠT:
     * - AFTER INSERT: Khi thêm mới bản ghi chấm công
     * - AFTER UPDATE: Khi cập nhật giờ tăng ca
     */
    
    -- Kiểm tra giờ tăng ca âm
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE GioTangCa < 0
    )
    BEGIN
        RAISERROR(N'Lỗi: Giờ tăng ca không được âm!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Kiểm tra giờ tăng ca quá lớn (> 12 giờ)
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE GioTangCa > 12
    )
    BEGIN
        DECLARE @GioTangCa_Vi_Pham DECIMAL(10,2);
        DECLARE @MaNV_Vi_Pham INT;
        DECLARE @Ngay_Vi_Pham DATE;
        
        SELECT TOP 1 
            @GioTangCa_Vi_Pham = GioTangCa,
            @MaNV_Vi_Pham = MaNV,
            @Ngay_Vi_Pham = Ngay
        FROM inserted 
        WHERE GioTangCa > 12;
        
        DECLARE @ErrorMsg NVARCHAR(500);
        SET @ErrorMsg = N'Lỗi: Giờ tăng ca không hợp lệ! ' +
                       N'Nhân viên mã ' + CAST(@MaNV_Vi_Pham AS NVARCHAR(10)) + 
                       N' ngày ' + CONVERT(NVARCHAR(10), @Ngay_Vi_Pham, 103) +
                       N' có giờ tăng ca = ' + CAST(@GioTangCa_Vi_Pham AS NVARCHAR(10)) + 
                       N' giờ (tối đa 12 giờ/ngày)';
        
        RAISERROR(@ErrorMsg, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
CÁCH HOẠT ĐỘNG:
- Trigger tự động chạy SAU KHI (AFTER) có lệnh INSERT hoặc UPDATE vào BangChamCong
- Không cần gọi thủ công, SQL Server sẽ tự động kích hoạt

VÍ DỤ TEST:

-- Test 1: Chấm công hợp lệ (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-22', 1.0, 3.5);
-- Kết quả: Thành công

-- Test 2: Giờ tăng ca âm (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-23', 1.0, -2);
-- Kết quả: Lỗi "Giờ tăng ca không được âm!"

-- Test 3: Giờ tăng ca quá lớn (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-24', 1.0, 15);
-- Kết quả: Lỗi "Giờ tăng ca không hợp lệ! ... (tối đa 12 giờ/ngày)"

-- Test 4: Cập nhật giờ tăng ca không hợp lệ (Sẽ bị chặn)
UPDATE BangChamCong
SET GioTangCa = 20
WHERE MaNV = 1 AND Ngay = '2025-11-22';
-- Kết quả: Lỗi

KIỂM TRA TRIGGER ĐÃ TỒN TẠI:
SELECT * FROM sys.triggers WHERE name = 'trg_ValidateGioTangCa';
*/

PRINT N'✓ Trigger trg_ValidateGioTangCa đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6: TRIGGER VALIDATE NGÀY CÔNG HỢP LỆ
-- ======================================================================================
-- Tên: trg_ValidateNgayCong
-- Mục đích: Tự động kiểm tra ngày công hợp lệ khi INSERT/UPDATE vào BangChamCong
-- Điều kiện: Ngày công chỉ được phép là 0, 0.5, hoặc 1.0
-- Hành động: Chặn và báo lỗi nếu ngày công không hợp lệ
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa trigger cũ nếu tồn tại để tạo lại
IF OBJECT_ID('trg_ValidateNgayCong', 'TR') IS NOT NULL 
    DROP TRIGGER trg_ValidateNgayCong;
GO

-- [UC6] [CHỨC NĂNG]: Validate ngày công hợp lệ (0, 0.5, hoặc 1.0)
CREATE TRIGGER trg_ValidateNgayCong 
ON BangChamCong 
AFTER INSERT, UPDATE
AS 
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * LOGIC KIỂM TRA:
     * 
     * 1. Ngày công chỉ được phép 3 giá trị:
     *    - 0: Nghỉ (không tính công)
     *    - 0.5: Làm nửa ngày (4 giờ)
     *    - 1.0: Làm cả ngày (8 giờ)
     * 
     * 2. Các giá trị khác đều không hợp lệ:
     *    - VD: 0.25, 0.75, 1.5, 2.0, v.v.
     * 
     * 3. Nếu vi phạm: RAISERROR và ROLLBACK TRANSACTION
     * 
     * LÝ DO GIỚI HẠN:
     * - Đơn giản hóa tính toán lương
     * - Dễ dàng quản lý và kiểm soát
     * - Tránh nhập liệu sai
     * 
     * THỜI ĐIỂM KÍCH HOẠT:
     * - AFTER INSERT: Khi thêm mới bản ghi chấm công
     * - AFTER UPDATE: Khi cập nhật ngày công
     */
    
    -- Kiểm tra ngày công không hợp lệ
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE NgayCong NOT IN (0, 0.5, 1.0)
    )
    BEGIN
        DECLARE @NgayCong_Vi_Pham DECIMAL(10,2);
        DECLARE @MaNV_Vi_Pham INT;
        DECLARE @Ngay_Vi_Pham DATE;
        
        SELECT TOP 1 
            @NgayCong_Vi_Pham = NgayCong,
            @MaNV_Vi_Pham = MaNV,
            @Ngay_Vi_Pham = Ngay
        FROM inserted 
        WHERE NgayCong NOT IN (0, 0.5, 1.0);
        
        DECLARE @ErrorMsg NVARCHAR(500);
        SET @ErrorMsg = N'Lỗi: Ngày công không hợp lệ! ' +
                       N'Nhân viên mã ' + CAST(@MaNV_Vi_Pham AS NVARCHAR(10)) + 
                       N' ngày ' + CONVERT(NVARCHAR(10), @Ngay_Vi_Pham, 103) +
                       N' có ngày công = ' + CAST(@NgayCong_Vi_Pham AS NVARCHAR(10)) + 
                       N'. Chỉ chấp nhận: 0 (nghỉ), 0.5 (nửa ngày), 1.0 (cả ngày)';
        
        RAISERROR(@ErrorMsg, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Kiểm tra ngày công âm (phòng trường hợp)
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE NgayCong < 0
    )
    BEGIN
        RAISERROR(N'Lỗi: Ngày công không được âm!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
CÁCH HOẠT ĐỘNG:
- Trigger tự động chạy SAU KHI (AFTER) có lệnh INSERT hoặc UPDATE vào BangChamCong
- Không cần gọi thủ công, SQL Server sẽ tự động kích hoạt

VÍ DỤ TEST:

-- Test 1: Ngày công hợp lệ - Cả ngày (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-22', 1.0, 2.0);
-- Kết quả: Thành công

-- Test 2: Ngày công hợp lệ - Nửa ngày (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-23', 0.5, 0);
-- Kết quả: Thành công

-- Test 3: Ngày công hợp lệ - Nghỉ (Thành công)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-24', 0, 0);
-- Kết quả: Thành công

-- Test 4: Ngày công không hợp lệ - 0.75 (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-25', 0.75, 0);
-- Kết quả: Lỗi "Ngày công không hợp lệ! ... Chỉ chấp nhận: 0, 0.5, 1.0"

-- Test 5: Ngày công không hợp lệ - 1.5 (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-26', 1.5, 0);
-- Kết quả: Lỗi

-- Test 6: Ngày công âm (Sẽ bị chặn)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-27', -1, 0);
-- Kết quả: Lỗi "Ngày công không được âm!"

KIỂM TRA TRIGGER ĐÃ TỒN TẠI:
SELECT * FROM sys.triggers WHERE name = 'trg_ValidateNgayCong';
*/

PRINT N'✓ Trigger trg_ValidateNgayCong đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC13: TRIGGER TỰ ĐỘNG CẬP NHẬT BẢNG LƯƠNG KHI CHẤM CÔNG THAY ĐỔI
-- ======================================================================================
-- Tên: trg_AutoUpdateBangLuong
-- Mục đích: Tự động cập nhật lại bảng lương khi có thay đổi chấm công
-- Điều kiện: Khi INSERT/UPDATE/DELETE vào BangChamCong và đã có bảng lương tháng đó
-- Hành động: Tính lại tổng giờ tăng ca trong BangLuong
-- ======================================================================================

USE QL_LuongNV;
GO

-- Xóa trigger cũ nếu tồn tại để tạo lại
IF OBJECT_ID('trg_AutoUpdateBangLuong', 'TR') IS NOT NULL 
    DROP TRIGGER trg_AutoUpdateBangLuong;
GO

-- [UC13] [CHỨC NĂNG]: Tự động cập nhật bảng lương khi chấm công thay đổi
CREATE TRIGGER trg_AutoUpdateBangLuong 
ON BangChamCong 
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * LOGIC TỰ ĐỘNG CẬP NHẬT:
     * 
     * 1. KHI THÊM MỚI CHẤM CÔNG (INSERT):
     *    - Kiểm tra xem đã có bảng lương của tháng đó chưa
     *    - Nếu có: Cập nhật lại TongGioTangCa trong BangLuong
     * 
     * 2. KHI SỬA CHẤM CÔNG (UPDATE):
     *    - Tính lại tổng giờ tăng ca
     *    - Cập nhật vào BangLuong
     * 
     * 3. KHI XÓA CHẤM CÔNG (DELETE):
     *    - Trừ đi giờ tăng ca đã xóa
     *    - Cập nhật vào BangLuong
     * 
     * LƯU Ý:
     * - Chỉ cập nhật nếu BangLuong đã tồn tại
     * - Nếu chưa có BangLuong, không làm gì (chờ chạy sp_TinhBangLuong_Thang)
     * - Trigger này giúp đồng bộ dữ liệu tự động
     */
    
    -- ============================================================
    -- XỬ LÝ INSERT VÀ UPDATE
    -- ============================================================
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Cập nhật tổng giờ tăng ca cho các nhân viên bị ảnh hưởng
        UPDATE bl
        SET bl.TongGioTangCa = (
            SELECT ISNULL(SUM(cc.GioTangCa), 0)
            FROM BangChamCong cc
            WHERE cc.MaNV = bl.MaNV
              AND MONTH(cc.Ngay) = bl.Thang
              AND YEAR(cc.Ngay) = bl.Nam
        )
        FROM BangLuong bl
        INNER JOIN inserted i ON bl.MaNV = i.MaNV
        WHERE bl.Thang = MONTH(i.Ngay)
          AND bl.Nam = YEAR(i.Ngay);
        
        -- Thông báo nếu có cập nhật
        IF @@ROWCOUNT > 0
        BEGIN
            PRINT N'→ Đã tự động cập nhật bảng lương do thay đổi chấm công';
        END
    END
    
    -- ============================================================
    -- XỬ LÝ DELETE
    -- ============================================================
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Cập nhật tổng giờ tăng ca cho các nhân viên bị ảnh hưởng
        UPDATE bl
        SET bl.TongGioTangCa = (
            SELECT ISNULL(SUM(cc.GioTangCa), 0)
            FROM BangChamCong cc
            WHERE cc.MaNV = bl.MaNV
              AND MONTH(cc.Ngay) = bl.Thang
              AND YEAR(cc.Ngay) = bl.Nam
        )
        FROM BangLuong bl
        INNER JOIN deleted d ON bl.MaNV = d.MaNV
        WHERE bl.Thang = MONTH(d.Ngay)
          AND bl.Nam = YEAR(d.Ngay);
        
        -- Thông báo nếu có cập nhật
        IF @@ROWCOUNT > 0
        BEGIN
            PRINT N'→ Đã tự động cập nhật bảng lương do xóa chấm công';
        END
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
CÁCH HOẠT ĐỘNG:
- Trigger tự động chạy SAU KHI (AFTER) có lệnh INSERT, UPDATE, hoặc DELETE vào BangChamCong
- Không cần gọi thủ công, SQL Server sẽ tự động kích hoạt
- Chỉ cập nhật nếu BangLuong đã tồn tại

VÍ DỤ TEST:

-- CHUẨN BỊ: Tính bảng lương tháng 11/2025
EXEC sp_TinhBangLuong_Thang @Thang_BangLuong = 11, @Nam_BangLuong = 2025;

-- Kiểm tra tổng giờ tăng ca hiện tại của nhân viên mã 1
SELECT MaNV, Thang, Nam, TongGioTangCa, LuongThucNhan
FROM BangLuong
WHERE MaNV = 1 AND Thang = 11 AND Nam = 2025;

-- Test 1: Thêm chấm công mới (Trigger sẽ tự động cập nhật BangLuong)
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-25', 1.0, 3.0);
-- Kết quả: Thông báo "Đã tự động cập nhật bảng lương..."

-- Kiểm tra lại BangLuong (TongGioTangCa đã tăng thêm 3 giờ)
SELECT MaNV, Thang, Nam, TongGioTangCa, LuongThucNhan
FROM BangLuong
WHERE MaNV = 1 AND Thang = 11 AND Nam = 2025;

-- Test 2: Sửa giờ tăng ca (Trigger sẽ tự động cập nhật)
UPDATE BangChamCong
SET GioTangCa = 5.0
WHERE MaNV = 1 AND Ngay = '2025-11-25';
-- Kết quả: BangLuong được cập nhật tự động

-- Test 3: Xóa chấm công (Trigger sẽ tự động cập nhật)
DELETE FROM BangChamCong
WHERE MaNV = 1 AND Ngay = '2025-11-25';
-- Kết quả: BangLuong được cập nhật tự động

LƯU Ý:
- Trigger chỉ cập nhật TongGioTangCa
- LuongThucNhan sẽ tự động tính lại nhờ Computed Column
- Nếu chưa có BangLuong, trigger không làm gì

KIỂM TRA TRIGGER ĐÃ TỒN TẠI:
SELECT * FROM sys.triggers WHERE name = 'trg_AutoUpdateBangLuong';
*/

PRINT N'✓ Trigger trg_AutoUpdateBangLuong đã được tạo/cập nhật thành công!';
GO
-- ======================================================================================
-- UC6: TRIGGER GHI LOG THAY ĐỔI CHẤM CÔNG
-- ======================================================================================
-- Tên: trg_LogChamCongChanges
-- Mục đích: Ghi lại lịch sử thay đổi chấm công để kiểm tra và audit
-- Điều kiện: Khi INSERT/UPDATE/DELETE vào BangChamCong
-- Hành động: Lưu thông tin thay đổi vào bảng Log_ChamCong
-- ======================================================================================

USE QL_LuongNV;
GO

-- ============================================================
-- BƯỚC 1: TẠO BẢNG LOG (NẾU CHƯA TỒN TẠI)
-- ============================================================
IF OBJECT_ID('dbo.Log_ChamCong', 'U') IS NULL
BEGIN
    CREATE TABLE Log_ChamCong (
        LogID INT IDENTITY(1,1) PRIMARY KEY,           -- ID tự động tăng
        HanhDong NVARCHAR(10),                         -- INSERT, UPDATE, DELETE
        MaNV INT,                                      -- Mã nhân viên
        Ngay DATE,                                     -- Ngày chấm công
        NgayCong_Cu DECIMAL(10,2),                     -- Ngày công cũ (trước khi thay đổi)
        NgayCong_Moi DECIMAL(10,2),                    -- Ngày công mới (sau khi thay đổi)
        GioTangCa_Cu DECIMAL(10,2),                    -- Giờ tăng ca cũ
        GioTangCa_Moi DECIMAL(10,2),                   -- Giờ tăng ca mới
        ThoiGian DATETIME DEFAULT GETDATE(),           -- Thời gian thay đổi
        NguoiThucHien NVARCHAR(100) DEFAULT SUSER_SNAME() -- Người thực hiện
    );
    
    PRINT N'✓ Đã tạo bảng Log_ChamCong để lưu lịch sử thay đổi';
END
GO

-- ============================================================
-- BƯỚC 2: TẠO TRIGGER GHI LOG
-- ============================================================

-- Xóa trigger cũ nếu tồn tại để tạo lại
IF OBJECT_ID('trg_LogChamCongChanges', 'TR') IS NOT NULL 
    DROP TRIGGER trg_LogChamCongChanges;
GO

-- [UC6] [CHỨC NĂNG]: Ghi log mọi thay đổi vào bảng chấm công
CREATE TRIGGER trg_LogChamCongChanges 
ON BangChamCong 
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- Tắt thông báo số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    /*
     * LOGIC GHI LOG:
     * 
     * 1. KHI THÊM MỚI (INSERT):
     *    - Ghi log với HanhDong = 'INSERT'
     *    - NgayCong_Cu và GioTangCa_Cu = NULL
     *    - NgayCong_Moi và GioTangCa_Moi = giá trị mới
     * 
     * 2. KHI CẬP NHẬT (UPDATE):
     *    - Ghi log với HanhDong = 'UPDATE'
     *    - Lưu cả giá trị cũ và mới
     * 
     * 3. KHI XÓA (DELETE):
     *    - Ghi log với HanhDong = 'DELETE'
     *    - NgayCong_Moi và GioTangCa_Moi = NULL
     *    - NgayCong_Cu và GioTangCa_Cu = giá trị trước khi xóa
     * 
     * MỤC ĐÍCH:
     * - Theo dõi ai đã thay đổi gì, khi nào
     * - Phục vụ audit và kiểm tra
     * - Có thể khôi phục dữ liệu nếu cần
     */
    
    -- ============================================================
    -- XỬ LÝ INSERT (THÊM MỚI)
    -- ============================================================
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Log_ChamCong (
            HanhDong, MaNV, Ngay, 
            NgayCong_Cu, NgayCong_Moi, 
            GioTangCa_Cu, GioTangCa_Moi
        )
        SELECT 
            'INSERT',
            i.MaNV,
            i.Ngay,
            NULL,           -- Không có giá trị cũ
            i.NgayCong,
            NULL,           -- Không có giá trị cũ
            i.GioTangCa
        FROM inserted i;
    END
    
    -- ============================================================
    -- XỬ LÝ UPDATE (CẬP NHẬT)
    -- ============================================================
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Log_ChamCong (
            HanhDong, MaNV, Ngay, 
            NgayCong_Cu, NgayCong_Moi, 
            GioTangCa_Cu, GioTangCa_Moi
        )
        SELECT 
            'UPDATE',
            i.MaNV,
            i.Ngay,
            d.NgayCong,     -- Giá trị cũ
            i.NgayCong,     -- Giá trị mới
            d.GioTangCa,    -- Giá trị cũ
            i.GioTangCa     -- Giá trị mới
        FROM inserted i
        INNER JOIN deleted d ON i.MaNV = d.MaNV AND i.Ngay = d.Ngay;
    END
    
    -- ============================================================
    -- XỬ LÝ DELETE (XÓA)
    -- ============================================================
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO Log_ChamCong (
            HanhDong, MaNV, Ngay, 
            NgayCong_Cu, NgayCong_Moi, 
            GioTangCa_Cu, GioTangCa_Moi
        )
        SELECT 
            'DELETE',
            d.MaNV,
            d.Ngay,
            d.NgayCong,     -- Giá trị trước khi xóa
            NULL,           -- Không có giá trị mới
            d.GioTangCa,    -- Giá trị trước khi xóa
            NULL            -- Không có giá trị mới
        FROM deleted d;
    END
END;
GO

-- ======================================================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ======================================================================================
/*
CÁCH HOẠT ĐỘNG:
- Trigger tự động chạy SAU KHI (AFTER) có lệnh INSERT, UPDATE, hoặc DELETE vào BangChamCong
- Tất cả thay đổi đều được ghi vào bảng Log_ChamCong
- Không cần gọi thủ công

VÍ DỤ TEST:

-- Test 1: Thêm chấm công mới
INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa)
VALUES (1, '2025-11-22', 1.0, 2.5);

-- Xem log
SELECT * FROM Log_ChamCong ORDER BY LogID DESC;

-- Test 2: Cập nhật giờ tăng ca
UPDATE BangChamCong
SET GioTangCa = 4.0
WHERE MaNV = 1 AND Ngay = '2025-11-22';

-- Xem log (sẽ thấy cả giá trị cũ và mới)
SELECT * FROM Log_ChamCong ORDER BY LogID DESC;

-- Test 3: Xóa chấm công
DELETE FROM BangChamCong
WHERE MaNV = 1 AND Ngay = '2025-11-22';

-- Xem log
SELECT * FROM Log_ChamCong ORDER BY LogID DESC;

-- XEM LỊCH SỬ THAY ĐỔI CỦA 1 NHÂN VIÊN:
SELECT 
    l.LogID,
    l.HanhDong,
    nv.HoTen,
    l.Ngay,
    l.NgayCong_Cu,
    l.NgayCong_Moi,
    l.GioTangCa_Cu,
    l.GioTangCa_Moi,
    l.ThoiGian,
    l.NguoiThucHien
FROM Log_ChamCong l
LEFT JOIN NhanVien nv ON l.MaNV = nv.MaNV
WHERE l.MaNV = 1
ORDER BY l.ThoiGian DESC;

-- XEM THỐNG KÊ THAY ĐỔI THEO HÀNH ĐỘNG:
SELECT 
    HanhDong,
    COUNT(*) AS N'Số lần',
    MIN(ThoiGian) AS N'Lần đầu',
    MAX(ThoiGian) AS N'Lần cuối'
FROM Log_ChamCong
GROUP BY HanhDong;

KIỂM TRA TRIGGER ĐÃ TỒN TẠI:
SELECT * FROM sys.triggers WHERE name = 'trg_LogChamCongChanges';
*/

PRINT N'✓ Trigger trg_LogChamCongChanges đã được tạo/cập nhật thành công!';
GO


---- bỏ đi dòng này (1 row(s) affected)
----======================== Nguyễn Chí Tâm ========================
---- Thêm thưởng/phạt và cập nhật bảng lương (sp_ThemThuongPhat_AndCapNhatBangLuong)
CREATE OR ALTER PROCEDURE sp_ThemThuongPhat_AndCapNhatBangLuong
    @MaNV   INT,
    @Loai   NVARCHAR(20),   -- N'Thưởng' hoặc N'Phạt'
    @SoTien DECIMAL(18,2),  -- > 0
    @LyDo   NVARCHAR(200) = NULL,
    @Thangg INT,
    @Namm   INT
AS
BEGIN
    SET NOCOUNT ON; 

    -- Kiểm tra đầu vào
    IF @MaNV IS NULL OR @MaNV <= 0
    BEGIN
        RAISERROR(N'MaNV không hợp lệ.', 16, 1);
        RETURN;
    END
    IF @Loai NOT IN (N'Thưởng', N'Phạt')
    BEGIN
        RAISERROR(N'Loại phải là N''Thưởng'' hoặc N''Phạt''.', 16, 1);
        RETURN;
    END
    IF @SoTien IS NULL OR @SoTien <= 0
    BEGIN
        RAISERROR(N'Số tiền phải > 0.', 16, 1);
        RETURN;
    END
    IF @Thangg NOT BETWEEN 1 AND 12 OR @Namm < 2000
    BEGIN
        RAISERROR(N'Kỳ lương (Tháng/Năm) không hợp lệ.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- 1) Kiểm tra tồn tại nhân viên
        IF NOT EXISTS (SELECT 1 FROM NhanVien WITH (NOLOCK) WHERE MaNV = @MaNV)
        BEGIN
            RAISERROR(N'Nhân viên không tồn tại.', 16, 1);
        END

        -- 2) Thêm vào ThuongPhat
        INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo)
        VALUES (@MaNV, @Thangg, @Namm, @Loai, @SoTien, @LyDo);

        -- 3) Đảm bảo có dòng BangLuong cho kỳ này (upsert)
        IF NOT EXISTS (
            SELECT 1 FROM BangLuong WITH (NOLOCK)
            WHERE MaNV = @MaNV AND Thang = @Thangg AND Nam = @Namm
        )
        BEGIN
            DECLARE @LuongCoBan DECIMAL(18,2) = NULL;

            -- Lấy lương cơ bản từ HopDong "còn hiệu lực" trong kỳ
            ;WITH Ky AS (
                SELECT 
                    CAST(CONCAT(@Namm, RIGHT(CONCAT('00', @Thangg), 2), '01') AS DATE) AS StartDate,
                    EOMONTH(CAST(CONCAT(@Namm, RIGHT(CONCAT('00', @Thangg), 2), '01') AS DATE)) AS EndDate
            )
            SELECT TOP 1 @LuongCoBan = h.LuongCoBan
            FROM HopDong h
            CROSS JOIN Ky k
            WHERE h.MaNV = @MaNV
              AND h.NgayBatDau <= k.EndDate
              AND (h.NgayKetThuc IS NULL OR h.NgayKetThuc >= k.StartDate)
            ORDER BY h.NgayBatDau DESC;

            INSERT INTO BangLuong (MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
            VALUES (@MaNV, @Thangg, @Namm, @LuongCoBan, 0, 0, 0);
        END

        -- 4) Tính lại tổng thưởng/phạt cho kỳ: Thưởng cộng, Phạt trừ
        DECLARE @TongThuongPhat DECIMAL(18,2) = 0;
        SELECT @TongThuongPhat = ISNULL(SUM(CASE WHEN Loai = N'Thưởng' THEN SoTien
                                                 WHEN Loai = N'Phạt'   THEN -SoTien
                                                 ELSE 0 END), 0)
        FROM ThuongPhat WITH (NOLOCK)
        WHERE MaNV = @MaNV AND Thangg = @Thangg AND Namm = @Namm;

        -- 5) Cập nhật BangLuong
        UPDATE BangLuong
        SET TongThuongPhat = @TongThuongPhat
        WHERE MaNV = @MaNV AND Thang = @Thangg AND Nam = @Namm;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrSeverity INT = ERROR_SEVERITY(),
                @ErrState INT = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
    END CATCH
END
GO

-- Giả sử bạn muốn thêm một khoản thưởng cho nhân viên có MaNV = 1
-- trong kỳ Tháng 11, Năm 2025, số tiền 2,000, lý do "Thưởng dự án"

EXEC sp_ThemThuongPhat_AndCapNhatBangLuong
    @MaNV   = 1,
    @Loai   = N'Thưởng',
    @SoTien = 2000,
    @LyDo   = N'Thưởng dự án',
    @Thangg = 11,
    @Namm   = 2025;
go

SELECT * FROM ThuongPhat WHERE MaNV = 3;
SELECT * FROM BangLuong WHERE MaNV = 3 
go
EXEC sp_ThemThuongPhat_AndCapNhatBangLuong
    @MaNV   = 3,
    @Loai   = N'Phạt',
    @SoTien = 500,
    @LyDo   = N'Đi trễ nhiều lần',
    @Thangg = 11,
    @Namm   = 2025;
go

SELECT * FROM ThuongPhat WHERE MaNV = 3;
SELECT * FROM BangLuong WHERE MaNV = 3 


--DROP PROCEDURE dbo.sp_ThemThuongPhat_AndCapNhatBangLuong;



-- Tính tổng thưởng/phạt (fn_TongThuongPhat_NV)

CREATE OR ALTER FUNCTION fn_TongThuongPhat_NV
(
    @MaNV   INT,
    @Thangg INT,
    @Namm   INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);

    SELECT @Tong = ISNULL(SUM(
        CASE 
            WHEN Loai = N'Thưởng' THEN SoTien
            WHEN Loai = N'Phạt'   THEN -SoTien
            ELSE 0
        END
    ), 0)
    FROM ThuongPhat
    WHERE MaNV = @MaNV
      AND Thangg = @Thangg
      AND Namm = @Namm;

    RETURN @Tong;
END
GO

SELECT dbo.fn_TongThuongPhat_NV(1, 11, 2025) AS TongThuongPhat;

-- Hàm lấy lương cơ bản hiện tại (fn_LayLuongCoBan_NV)
CREATE OR ALTER FUNCTION fn_LayLuongCoBan_NV
(
    @MaNV INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @LuongCoBan DECIMAL(18,2);

    -- Lấy hợp đồng còn hiệu lực tại thời điểm hiện tại
    SELECT TOP 1 @LuongCoBan = h.LuongCoBan
    FROM HopDong h
    WHERE h.MaNV = @MaNV
      AND h.NgayBatDau <= GETDATE()
      AND (h.NgayKetThuc IS NULL OR h.NgayKetThuc >= GETDATE())
    ORDER BY h.NgayBatDau DESC;  -- lấy hợp đồng mới nhất

    RETURN ISNULL(@LuongCoBan, 0);
END
GO

SELECT dbo.fn_LayLuongCoBan_NV(2) AS LuongCoBanHienTai;


-- Hàm tính lương thực nhận (fn_TinhLuongThucNhan)
CREATE OR ALTER FUNCTION fn_TinhLuongThucNhan
(
    @MaNV   INT,
    @Thang  INT,
    @Nam    INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @LuongThucNhan DECIMAL(18,2);

    SELECT @LuongThucNhan =
        ISNULL(LuongCoBan,0)
        + ISNULL(TongPhuCap,0)
        + ISNULL(TongThuongPhat,0)
        + ISNULL(TongGioTangCa,0) * 50000
    FROM BangLuong
    WHERE MaNV = @MaNV
      AND Thang = @Thang
      AND Nam   = @Nam;

    RETURN ISNULL(@LuongThucNhan,0);
END
GO

SELECT dbo.fn_TinhLuongThucNhan(1, 11, 2025) AS LuongThucNhan;

-- Trigger cộng thưởng/phạt vào bảng lương (trg_AfterInsert_ThuongPhat)
CREATE OR ALTER TRIGGER trg_AfterInsert_ThuongPhat
ON ThuongPhat
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật bảng lương cho từng nhân viên vừa được thêm thưởng/phạt
    UPDATE bl
    SET bl.TongThuongPhat = bl.TongThuongPhat 
                            + ISNULL(tp.TongCong,0)
    FROM BangLuong bl
    INNER JOIN (
        -- Gom tổng thưởng/phạt từ các bản ghi mới thêm
        SELECT i.MaNV, i.Thangg, i.Namm,
               SUM(CASE WHEN i.Loai = N'Thưởng' THEN i.SoTien
                        WHEN i.Loai = N'Phạt'   THEN -i.SoTien
                        ELSE 0 END) AS TongCong
        FROM inserted i
        GROUP BY i.MaNV, i.Thangg, i.Namm
    ) tp
      ON bl.MaNV = tp.MaNV
     AND bl.Thang = tp.Thangg
     AND bl.Nam   = tp.Namm;

    -- Nếu chưa có dòng BangLuong cho kỳ này thì thêm mới
    INSERT INTO BangLuong (MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
    SELECT i.MaNV, i.Thangg, i.Namm,
           -- Lấy lương cơ bản từ hợp đồng còn hiệu lực
           (
               SELECT TOP 1 h.LuongCoBan
               FROM HopDong h
               WHERE h.MaNV = i.MaNV
                 AND h.NgayBatDau <= EOMONTH(CAST(CONCAT(i.Namm, RIGHT(CONCAT('00', i.Thangg), 2), '01') AS DATE))
                 AND (h.NgayKetThuc IS NULL OR h.NgayKetThuc >= CAST(CONCAT(i.Namm, RIGHT(CONCAT('00', i.Thangg), 2), '01') AS DATE))
               ORDER BY h.NgayBatDau DESC
           ) AS LuongCoBan,
           0 AS TongPhuCap,
           SUM(CASE WHEN i.Loai = N'Thưởng' THEN i.SoTien
                    WHEN i.Loai = N'Phạt'   THEN -i.SoTien
                    ELSE 0 END) AS TongThuongPhat,
           0 AS TongGioTangCa
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM BangLuong bl
        WHERE bl.MaNV = i.MaNV AND bl.Thang = i.Thangg AND bl.Nam = i.Namm
    )
    GROUP BY i.MaNV, i.Thangg, i.Namm;
END
GO

SELECT * FROM BangLuong WHERE MaNV = 1 

INSERT INTO ThuongPhat (MaNV, Thangg, Namm, Loai, SoTien, LyDo)
VALUES (1, 11, 2025, N'Thưởng', 2000, N'Thưởng dự án');

SELECT * FROM BangLuong WHERE MaNV = 1 

select * From NhanVien
select * From TaiKhoan