-- ======================================================================================
-- [FINAL SCRIPT] QUẢN LÝ LƯƠNG NHÂN VIÊN (FULL OPTIMIZED)
-- ======================================================================================

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
    LuongHienTai decimal(18,2), -- Lương hiển thị nhanh
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

CREATE TABLE LichSuXoaNhanVien (ID INT IDENTITY(1,1) PRIMARY KEY, MaNV INT, HoTen NVARCHAR(40), NgayXoa DATETIME, LyDo NVARCHAR(200));
CREATE TABLE LichSuTaiKhoan (ID INT IDENTITY(1,1) PRIMARY KEY, MaNV INT, TenDangNhap NVARCHAR(50), NgayTao DATETIME DEFAULT GETDATE());
CREATE TABLE LuongCoBanLog (ID INT IDENTITY(1,1) PRIMARY KEY, MaCV INT, MucLuongCu DECIMAL(18,2), MucLuongMoi DECIMAL(18,2), NgayCapNhat DATETIME DEFAULT GETDATE());
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
INSERT INTO Roles (TenRole) VALUES (N'Admin'), (N'NhanSu'), (N'KeToan'), (N'NhanVien');
INSERT INTO PhongBan(TenPB) VALUES (N'Phòng Nhân Sự'), (N'Phòng Kế Toán'), (N'Phòng IT'), (N'Phòng Kinh Doanh'), (N'Phòng Marketing'), (N'Phòng Hành Chính');
INSERT INTO ChucVu(TenCV,HeSoLuong) VALUES (N'Nhân viên',1.20), (N'Trưởng phòng',2.00), (N'Giám đốc',3.50), (N'Phó phòng', 1.70), (N'Kế toán trưởng', 2.20);
INSERT INTO LuongCoBan(MaCV, MucLuong) VALUES (1, 8000000), (2, 12000000), (3, 20000000), (4, 10000000), (5, 13000000);
GO

-- PHẦN 3: CÁC HÀM (FUNCTIONS)
-- ======================================================================================

-- [PHÚC] Tính tổng phụ cấp
CREATE FUNCTION fn_TongPhuCap_NV(@MaNV int) RETURNS decimal(18,2) AS  
BEGIN
    DECLARE @Tong decimal(18,2); SELECT @Tong = Sum(SoTien) FROM PhuCap WHERE MaNV = @MaNV; RETURN ISNULL(@Tong,0);
END;
GO

-- [PHÚC] Tính tổng thưởng phạt lịch sử
CREATE FUNCTION fn_TongThuongPhat_NV_LichSu(@MaNV INT) RETURNS DECIMAL(18,2) AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    SELECT @Tong = SUM(CASE WHEN Loai = N'Thưởng' THEN SoTien WHEN Loai = N'Phạt' THEN -SoTien END)
    FROM ThuongPhat WHERE MaNV = @MaNV;
    RETURN ISNULL(@Tong,0);
END;
GO

-- [PHÚC] Kiểm tra hợp đồng active
CREATE FUNCTION fn_HopDongConHieuLuc(@MaNV int) RETURNS bit AS
BEGIN 
    IF EXISTS(SELECT 1 FROM HopDong WHERE MaNV = @MaNV AND (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())) RETURN 1; 
    RETURN 0; 
END;
GO

-- [PHÚC] Thống kê HĐ hết hạn
CREATE FUNCTION fn_SoLuongHopDongHetHan() RETURNS INT AS
BEGIN 
    RETURN (SELECT COUNT(*) FROM HopDong WHERE NgayKetThuc IS NOT NULL AND NgayKetThuc < GETDATE()); 
END;
GO

-- [PHÚC] Báo cáo chi phí phụ cấp
CREATE FUNCTION fn_TongPhuCapLoai(@LoaiPhuCap NVARCHAR(50) = NULL) RETURNS DECIMAL(18,2) AS
BEGIN 
    DECLARE @Tong DECIMAL(18,2); SELECT @Tong = SUM(SoTien) FROM PhuCap WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap; RETURN ISNULL(@Tong, 0); 
END;
GO

-- [TRƯỜNG] Các hàm tiện ích
CREATE FUNCTION fn_LayMaNhanVienTheoEmail(@Email NVARCHAR(60)) RETURNS INT AS
BEGIN
    DECLARE @MaNV INT; SELECT TOP 1 @MaNV = MaNV FROM NhanVien WHERE Email = @Email; RETURN ISNULL(@MaNV, 0);
END;
GO
CREATE FUNCTION fn_KiemTraNhanVienTonTai(@MaNV INT) RETURNS BIT AS
BEGIN RETURN (SELECT CASE WHEN EXISTS(SELECT 1 FROM NhanVien WHERE MaNV = @MaNV) THEN 1 ELSE 0 END); END;
GO
CREATE FUNCTION fn_LayQuyenTaiKhoan(@TenDangNhap NVARCHAR(50)) RETURNS NVARCHAR(20) AS
BEGIN DECLARE @Quyen NVARCHAR(20); SELECT @Quyen = Quyen FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap; RETURN ISNULL(@Quyen, N'User'); END;
GO
CREATE FUNCTION fn_DemNhanVienTrongPhong(@MaPB INT) RETURNS INT AS
BEGIN RETURN (SELECT COUNT(*) FROM NhanVien WHERE MaPB = @MaPB); END;
GO
CREATE FUNCTION fn_TrungBinhHeSoLuong() RETURNS DECIMAL(5,2) AS
BEGIN RETURN (SELECT AVG(HeSoLuong) FROM ChucVu); END;
GO

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

-- [PHÚC] Quản lý nhân sự
CREATE PROCEDURE sp_AddNhanVien @HoTen NVARCHAR(40), @NgaySinh DATE, @GioiTinh NVARCHAR(5), @DiaChi NVARCHAR(50), @DienThoai NVARCHAR(15), @Email NVARCHAR(60), @MaPB INT, @MaCV INT
AS BEGIN SET NOCOUNT ON; IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM NhanVien WHERE Email = @Email) BEGIN RAISERROR(N'Email đã tồn tại',16,1); RETURN; END
INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV) VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV); END;
GO

CREATE PROCEDURE sp_ThemHopDong @MaNV int, @NgayBatDau date, @NgayKetThuc date = null, @LoaiHD nvarchar(50), @Luongcoban decimal(18,2), @Ghichu nvarchar(200) = null 
AS BEGIN SET NOCOUNT ON; IF EXISTS (SELECT 1 FROM HopDong WHERE MaNV = @MaNV AND ((NgayKetThuc IS NOT NULL AND NgayKetThuc > GETDATE()) OR LoaiHD = N'Không thời hạn')) BEGIN RAISERROR(N'Nhân viên này đang có hợp đồng còn hiệu lực!',16,1); RETURN; END
INSERT INTO HopDong(MaNV,NgayBatDau,NgayKetThuc,LoaiHD,LuongCoBan,GhiChu) VALUES (@MaNV,@NgayBatDau,@NgayKetThuc,@LoaiHD,@Luongcoban,@Ghichu); END;
GO

CREATE PROCEDURE sp_ThemPhuCap @MaNV INT, @LoaiPhuCap NVARCHAR(50), @SoTien DECIMAL(18,2)
AS BEGIN SET NOCOUNT ON; IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV) BEGIN RAISERROR(N'Nhân viên không tồn tại!',16,1); RETURN; END
INSERT INTO PhuCap(MaNV,LoaiPhuCap,SoTien) VALUES(@MaNV,@LoaiPhuCap,@SoTien); END;
GO

CREATE PROCEDURE sp_QuanLyLuongCoBan @HanhDong NVARCHAR(10), @MaCV INT, @MucLuong DECIMAL(18,2) = NULL
AS BEGIN SET NOCOUNT ON; IF @HanhDong = N'Thêm' INSERT INTO LuongCoBan(MaCV,MucLuong) VALUES (@MaCV,@MucLuong);
ELSE IF @HanhDong = N'Sửa' UPDATE LuongCoBan SET MucLuong = @MucLuong WHERE MaCV = @MaCV;
ELSE IF @HanhDong = N'Xóa' DELETE FROM LuongCoBan WHERE MaCV = @MaCV; END;
GO

CREATE PROCEDURE sp_DanhSachHopDongNV @MaNV int = null AS BEGIN SELECT * FROM HopDong WHERE @MaNV IS NULL OR MaNV = @MaNV; END;
GO
CREATE PROCEDURE sp_TongPhuCapTheoLoai @LoaiPhuCap nvarchar(50) = null AS BEGIN SELECT LoaiPhuCap, SUM(SoTien) as TongPhuCap FROM PhuCap WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap GROUP BY LoaiPhuCap; END;
GO

-- [TRƯỜNG] Quản lý hệ thống
CREATE PROCEDURE sp_TaoTaiKhoan @TenDangNhap NVARCHAR(50), @MatKhau NVARCHAR(100), @MaNV INT, @Quyen NVARCHAR(20) = N'User', @MaRole INT = 4 
AS BEGIN SET NOCOUNT ON; 
IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV=@MaNV) BEGIN RAISERROR (N'Nhân viên không tồn tại',16,1); RETURN; END 
IF EXISTS (SELECT 1 FROM TaiKhoan WHERE TenDangNhap=@TenDangNhap) BEGIN RAISERROR (N'Tên đăng nhập đã tồn tại',16,1); RETURN; END 
IF @MaRole IS NULL SELECT @MaRole = MaRole FROM Roles WHERE TenRole = @Quyen; 
INSERT INTO TaiKhoan(TenDangNhap,MatKhau,MaNV,Quyen,MaRole) VALUES(@TenDangNhap,@MatKhau,@MaNV,@Quyen,@MaRole); END;
GO

CREATE PROCEDURE sp_CapNhatTrangThaiNV AS BEGIN UPDATE NhanVien SET TrangThai = N'Nghỉ việc' WHERE MaNV NOT IN (SELECT MaNV FROM HopDong WHERE (NgayKetThuc IS NULL OR NgayKetThuc > GETDATE())); END;
GO
CREATE PROCEDURE sp_QuanLyPhongBan @ThaoTac NVARCHAR(10), @MaPB INT = NULL, @TenPB NVARCHAR(50) = NULL AS BEGIN IF @ThaoTac = 'THEM' INSERT INTO PhongBan(TenPB) VALUES(@TenPB); ELSE IF @ThaoTac = 'SUA' UPDATE PhongBan SET TenPB = @TenPB WHERE MaPB = @MaPB; ELSE IF @ThaoTac = 'XOA' DELETE FROM PhongBan WHERE MaPB = @MaPB; END;
GO
CREATE PROCEDURE sp_QuanLyChucVu @ThaoTac NVARCHAR(10), @MaCV INT = NULL, @TenCV NVARCHAR(50) = NULL, @HeSoLuong DECIMAL(4,2) = NULL AS BEGIN IF @ThaoTac = 'THEM' INSERT INTO ChucVu(TenCV, HeSoLuong) VALUES(@TenCV, @HeSoLuong); ELSE IF @ThaoTac = 'SUA' UPDATE ChucVu SET TenCV = @TenCV, HeSoLuong = @HeSoLuong WHERE MaCV = @MaCV; ELSE IF @ThaoTac = 'XOA' DELETE FROM ChucVu WHERE MaCV = @MaCV; END;
GO
CREATE PROCEDURE sp_TaoBackup_QLLuong AS BEGIN DECLARE @File NVARCHAR(300); SET @File = 'D:\Backup_QLLuong\QL_Luong_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak'; BACKUP DATABASE QL_LuongNV TO DISK = @File WITH INIT, FORMAT, NAME = 'Backup tu dong CSDL QL_Luong'; END;
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
CREATE TRIGGER tr_HopDong_AfterUpdate ON HopDong AFTER UPDATE AS BEGIN UPDATE NhanVien SET TrangThai = N'Nghỉ việc' WHERE MaNV IN (SELECT i.MaNV FROM inserted i WHERE i.NgayKetThuc < GETDATE()); END;
GO
CREATE TRIGGER tr_HopDong_AlterInsert ON HopDong AFTER INSERT AS BEGIN UPDATE NhanVien SET TrangThai = N'Đang làm' WHERE MaNV IN (SELECT i.MaNV FROM inserted i WHERE i.NgayKetThuc IS NULL OR i.NgayKetThuc > GETDATE()); END;
GO
CREATE TRIGGER tr_NhanVien_AfterUpdate ON NhanVien AFTER UPDATE AS BEGIN UPDATE nv SET nv.LuongHienTai = lc.MucLuong FROM NhanVien nv JOIN inserted i ON nv.MaNV = i.MaNV JOIN LuongCoban lc ON i.MaCV = lc.MaCV WHERE i.MaCV <> (SELECT d.MaCV FROM deleted d WHERE d.MaNV = i.MaNV); END;
GO
CREATE TRIGGER tr_LuongCoBan_AfterUpdate ON LuongCoBan AFTER UPDATE AS BEGIN INSERT INTO LuongCoBanLog(MaCV, MucLuongCu, MucLuongMoi) SELECT d.MaCV, d.MucLuong, i.MucLuong FROM inserted i JOIN deleted d ON i.MaCV = d.MaCV WHERE i.MucLuong <> d.MucLuong; END;
GO
CREATE TRIGGER trg_TaoBangLuongKhiThemNV ON NhanVien AFTER INSERT AS BEGIN INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa) SELECT MaNV, MONTH(GETDATE()), YEAR(GETDATE()), 0, 0, 0, 0 FROM inserted; END;
GO

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

-- PHẦN 6: SINH DỮ LIỆU TỰ ĐỘNG (An toàn, có Try/Catch)
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
PRINT N'>>> Đang sinh dữ liệu mẫu...';
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
        
        -- Thêm phụ cấp ngẫu nhiên
        IF @i % 2 = 0 EXEC sp_ThemPhuCap @MaNV = @NewMaNV, @LoaiPhuCap = N'Xăng xe', @SoTien = 500000;

        SET @i = @i + 1;
    END TRY
    BEGIN CATCH SET @i = @i + 1; END CATCH
END;
PRINT N'>>> Đã sinh dữ liệu mẫu xong.';
GO

-- PHẦN 7: BẢO MẬT & PHÂN QUYỀN
-- ======================================================================================
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_NhanSu') CREATE ROLE role_NhanSu;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_KeToan') CREATE ROLE role_KeToan;
GO

-- Quyền Nhân sự
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

-- Quyền Kế toán
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
GRANT EXECUTE ON sp_ThemThuongPhat_AndCapNhatBangLuong TO role_KeToan; -- Quan trọng
GO

PRINT N'*** HỆ THỐNG ĐÃ CÀI ĐẶT THÀNH CÔNG ***';
PRINT N'Sử dụng câu lệnh SELECT * FROM TaiKhoan để lấy tài khoản đăng nhập.';
select * from TaiKhoan