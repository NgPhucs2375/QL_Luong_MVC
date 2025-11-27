create database QL_LuongNV
go
use QL_LuongNV

-- ================================================
-- CHƯƠNG 1: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ LƯƠNG
-- ================================================

--!Tên CSDL : QL_LuongNV !--
--!MỤC TIÊU : Quản lí thông tin nhân viên,phòng ban,chức vụ, bảng lương, chấm công, phục cấp, thưởng phạt,hợp đồng, và tính toán lưng thực hận hàng tháng !--

--!Các bảng chính (khoảng 10 bảng )
--!Tên Bảng : 1.PhongBan {Quản lý thông tin các phòng ban}
--!         : 2.ChucVu {Danh mục chức vụ và hệ số lương}
--!         : 3.NhanVien {Lưu thông tin nhân viên} 
--!         : 4.HopDong {Quản lý hợp đồng lao động}
--!         : 5.ChamCong {Ghi nhận ngày công, giờ tăng ca}
--!         : 6.LuongCoBan {Mức lương cơ bản theo từng chức vụ} 
--!         : 7.PhuCap {Các khoản phụ cấp theo nhân viên} 
--!         : 8.ThuongPhat {Thưởng và phạt theo tháng} 
--!         : 9.BangLuong {Bảng tổng hợp lương hàng tháng}
--!         : 10.TaiKhoan {Quản lý tài khoản đăng nhập hệ thống (nếu có phần mềm quản lý)}

--!======================================================================
--!                                 BẢNG                              !--
--!======================================================================

create table PhongBan
(
    MaPB int identity(1,1) not null primary key,
    TenPB nvarchar(50) not null Unique,
    NgayThanhLap Date Default GetDate()
)
GO

create table ChucVu
(
    MaCV int identity(1,1) not null primary key,
    TenCV nvarchar(50) not null unique,
    HeSoLuong Decimal(4,2) Check(HeSoLuong BETWEEN 1 AND 10)
)
GO

create table NhanVien
(
    MaNV int identity(1,1) not null primary key,
    HoTen nvarchar(40) not null,
    NgaySinh Date Check(NgaySinh <GetDate()),
    GioiTinh  nvarchar(5) DEFAULT N'Nam',
    DiaChi nvarchar(50),
    DienThoai nvarchar(15),
    Email nvarchar(60) unique,
    TrangThai nvarchar(25) DEFAULT N'Đang làm',
    MaCV int ,
    MaPB int ,
    constraint FK_MaCV_NhanVien foreign key (MaCV) references  ChucVu(MaCV),
    constraint FK_MaPB_NhanVien foreign key (MaPB) references  PhongBan(MaPB)
)
GO

create table HopDong
(
    MaHD int identity(1,1) not null primary key,
    MaNV int,
    NgayBatDau Date not null,
    NgayKetThuc Date,
    LoaiHD nvarchar(50) Check(LoaiHD in(N'Có thời hạn',N'Không thời hạn')),
    LuongCoBan decimal(18,2) check (LuongCoBan > 0),
    GhiChu nvarchar(200),
    constraint FK_MaNV_HopDong foreign key (MaNV) references NhanVien(MaNV)
)
GO

create table BangChamCong
(
    MaCC int identity(1,1) not null primary key,
    MaNV int,
    Ngay Date not null,
    NgayCong decimal(4,2) default 1.0 check(NgayCong BETWEEN 0 AND 1),
    GioTangCa decimal(5,2) default 0 check (GioTangCa >= 0),
    constraint FK_MaNV_BangChamCong foreign key (MaNV) references NhanVien(MaNV)
)
GO

create table PhuCap
(
    MaPC int identity(1,1) not null primary key,
    MaNV int ,
    LoaiPhuCap nvarchar(50),
    SoTien decimal(18,2) check(SoTien>=0),
    constraint FK_MaNV_PhuCap foreign key (MaNV) references NhanVien(MaNV)
)
GO

create table ThuongPhat
(
    MaTP int identity(1,1) not null primary key,
    MaNV int ,
	Thangg int check(Thangg BETWEEN 1 AND 12),
    Namm int check(Namm >=2000),
    Loai nvarchar(20) check (Loai in(N'Thưởng',N'Phạt')),
    SoTien decimal(18,2) check(SoTien>0),
    LyDo nvarchar(200),
    constraint FK_MaNV_ThuongPhat foreign key (MaNV) references NhanVien(MaNV)
)
GO

create table LuongCoban
(
    MaLCB int identity(1,1) not null primary key,
    MaCV int,
    MucLuong decimal(18,2) check (MucLuong>0),
    constraint Fk_MaCV_LuongCoBan foreign key (MaCV) references ChucVu(MaCV)
)
GO

create table BangLuong
(
    MaBangLuong int identity(1,1) not null primary key,
    MaNV int,
    Thang int check(Thang BETWEEN 1 AND 12),
    Nam int check(Nam >=2000),
    LuongCoBan decimal(18,2),
    TongPhuCap decimal(18,2),
    TongThuongPhat decimal(18,2),
    TongGioTangCa decimal(10,2),
    LuongThucNhan AS (LuongCoBan + ISNULL(TongPhuCap,0) + ISNULL(TongThuongPhat,0) + ISNULL(TongGioTangCa,0) * 50000),
    constraint FK_MANV_BangLuong foreign key (MaNV) references NhanVien(MaNV)
)
GO

create table TaiKhoan
(
    TenDangNhap nvarchar(50) not null primary key,
    MatKhau nvarchar(100) not null,
    MaNV int ,
    Quyen nvarchar(20) default N'User',
    constraint FK_MaNV_TaiKhoan foreign key (MaNV) references NhanVien(MaNV)
)
GO

-- ========================
-- DỮ LIỆU MẪU (Giữ 1 bản từ origin/Scu)
-- ========================

Insert into PhongBan(TenPB)
Values(N'Phòng Nhân Sự'),
(N'Phòng Kế Toán'),
(N'Phòng IT'),
(N'Phòng Kinh Doanh'),
(N'Phòng Marketing'),
(N'Phòng Hành Chính');
GO

Insert into ChucVu(TenCV,HeSoLuong)
Values(N'Nhân viên',1.20),
(N'Trưởng phòng',2.00),
(N'Giám đốc',3.50),
(N'Phó phòng', 1.70),
(N'Kế toán trưởng', 2.20);
GO

Insert into NhanVien(HoTen,NgaySinh,GioiTinh,DiaChi,DienThoai,Email,MaPB,MaCV)
Values(N'Nguyễn Văn A', '1995-05-12', N'Nam', N'Hà Nội', '0905123456', 'a.nguyen@company.vn', 1, 1),
(N'Trần Thị B', '1998-11-20', N'Nữ', N'Đà Nẵng', '0906789123', 'b.tran@company.vn', 2, 2),
(N'Lê Văn C', '1990-03-18', N'Nam', N'HCM', '0934567890', 'c.le@company.vn', 3, 3),
(N'Phạm Thị D', '1997-09-10', N'Nữ', N'Hải Phòng', '0975123999', 'd.pham@company.vn', 4, 1),
(N'Vũ Minh E', '1992-02-25', N'Nam', N'Nam Định', '0912555333', 'e.vu@company.vn', 1, 4),
(N'Lý Thị F', '1996-07-08', N'Nữ', N'Bắc Ninh', '0968888777', 'f.ly@company.vn', 2, 5),
(N'Đỗ Văn G', '1991-04-30', N'Nam', N'Ninh Bình', '0941234123', 'g.do@company.vn', 3, 1),
(N'Tạ Thị H', '1999-12-12', N'Nữ', N'Huế', '0933333111', 'h.ta@company.vn', 5, 4),
(N'Ngô Văn I', '1988-06-06', N'Nam', N'Quảng Nam', '0909090909', 'i.ngo@company.vn', 6, 2);
GO
select * from NhanVien
GO

INSERT INTO HopDong(MaNV, NgayBatDau, LoaiHD, LuongCoBan)
VALUES
(1, '2021-01-01', N'Có thời hạn', 8000000),
(2, '2020-07-01', N'Không thời hạn', 12000000),
(3, '2019-03-01', N'Không thời hạn', 20000000),
(4, '2022-05-10', N'Có thời hạn', 7000000),
(5, '2021-09-15', N'Không thời hạn', 10000000),
(6, '2023-01-05', N'Có thời hạn', 11000000),
(7, '2020-08-22', N'Không thời hạn', 9000000),
(8, '2024-02-01', N'Có thời hạn', 8500000),
(9, '2018-06-10', N'Không thời hạn', 15000000);
GO

INSERT INTO BangChamCong(MaNV, Ngay, NgayCong, GioTangCa)
VALUES
(1, '2025-10-01', 1, 2),
(2, '2025-10-01', 1, 0),
(3, '2025-10-01', 1, 1.5),
(4, '2025-10-01', 1, 0.5),
(5, '2025-10-01', 1, 1),
(6, '2025-10-01', 1, 0),
(7, '2025-10-01', 1, 2.5),
(8, '2025-10-01', 1, 0),
(9, '2025-10-01', 1, 1);
GO
select * from BangChamCong
GO

INSERT INTO PhuCap(MaNV, LoaiPhuCap, SoTien)
VALUES
(1, N'Xăng xe', 500000),
(2, N'Điện thoại', 700000),
(3, N'Trách nhiệm', 2000000),
(4, N'Ăn trưa', 400000),
(5, N'Đi lại', 600000),
(6, N'Nhà ở', 800000),
(7, N'Chuyên cần', 500000),
(8, N'Trợ cấp con nhỏ', 900000),
(9, N'Xăng xe', 700000);
GO
select * from  PhuCap
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

select * from ThuongPhat
GO

INSERT INTO LuongCoBan(MaCV, MucLuong)
VALUES
(1, 8000000),
(2, 12000000),
(3, 20000000),
(4, 10000000),
(5, 13000000);
GO
select * from LuongCoBan
GO

INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
VALUES
(1, 10, 2025, 8000000, 500000, 1000000, 2),
(2, 10, 2025, 12000000, 700000, -300000, 0),
(3, 10, 2025, 20000000, 2000000, 2000000, 1.5),
(4, 10, 2025, 7000000, 400000, 500000, 0.5),
(5, 10, 2025, 10000000, 600000, -200000, 1),
(6, 10, 2025, 11000000, 800000, 1000000, 0),
(7, 10, 2025, 9000000, 500000, 800000, 2.5),
(8, 10, 2025, 8500000, 900000, -300000, 0),
(9, 10, 2025, 15000000, 700000, 1500000, 1);
GO
select * from BangLuong
GO

INSERT INTO TaiKhoan (TenDangNhap, MatKhau, Quyen)
VALUES 
(N'admin', N'123456', N'Admin')
GO
select * from TaiKhoan
GO

-- ================================================
--         CHƯƠNG 2: CÀI ĐẶT YÊU CẦU XỬ LÝ
-- ================================================

-- Mục tiêu : Tạo dựng cài đặt yêu cầu xử lý cho dữ liệu được đặt ra
-- 1.Procedure :
-- 2.Function :
-- 3.Trigger :
-- 4.Cursor :
-- 5.Transaction :

--!======================================================================
--!                                 Yêu cầu                           !--
--!======================================================================

-- 1.Procedure (Thủ tục)

-- 1.Thêm nhân viên mới (check email có trùng lặp hay không)
-- Giải thích: dùng cột hiện có, tránh chèn vào cột không tồn tại.
create procedure sp_AddNhanVien  @HoTen NVARCHAR(40),@NgaySinh DATE,@GioiTinh NVARCHAR(5),@DiaChi NVARCHAR(50),@DienThoai NVARCHAR(15),@Email NVARCHAR(60),@MaPB INT,@MaCV INT
AS
    Begin 
        Set Nocount on;
        If @Email is not null and exists 
            (
                Select *                 from NhanVien 
                Where Email = @Email
            )
            begin 
                Raiserror(N'Email đã tồn tại',16,1);
                return ;
            end

        INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV)
        VALUES (@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV);
        
        print N'Đã thêm nhân viên : ' + @HoTen + N'vào hệ thống'
    End
GO

-- 2.Tính bảng lương cho 1 tháng (xóa cũ rồi chèn mới)
-- Giải thích: Luận lấy LươngCoBan từ HopDong nếu có, nếu không lấy từ LuongCoban.
create or alter procedure sp_TinhBangLuong_Thang @Thang int,@Nam int
AS
    Begin
        Set Nocount on;

        -- xóa các bản ghi đã có tcho tháng-năm này (nếu muốn làm mới)
        Delete from BangLuong
        where Thang = @Thang AND Nam = @Nam;

        Insert into BangLuong (MaNV,Thang,Nam,LuongCoBan,TongPhuCap,TongThuongPhat,TongGioTangCa)
        Select nv.MaNV,@Thang,@Nam,isnull(hd.LuongCoBan,isnull(lcb.MucLuong,0)),
            isnull((Select Sum(SoTien) From PhuCap pc where pc.MaNV = nv.MaNV),0),
            ISNULL((SELECT SUM(CASE WHEN tp.Loai = N'Thưởng' THEN tp.SoTien WHEN tp.Loai = N'Phạt' THEN -tp.SoTien END) FROM ThuongPhat tp WHERE tp.MaNV = nv.MaNV),0),
            ISNULL((SELECT SUM(cc.GioTangCa) FROM BangChamCong cc WHERE cc.MaNV = nv.MaNV AND MONTH(cc.Ngay)=@Thang AND YEAR(cc.Ngay)=@Nam),0)
          FROM NhanVien nv
          LEFT JOIN HopDong hd ON nv.MaNV = hd.MaNV
          LEFT JOIN LuongCoban lcb ON nv.MaCV = lcb.MaCV
          GROUP BY nv.MaNV, hd.LuongCoBan, lcb.MucLuong;

          PRINT N'Hoàn thành tính bảng lương cho ' + CAST(@Thang AS NVARCHAR(2)) + N'/' + CAST(@Nam AS NVARCHAR(4));

    End
GO


-- 4.Thêm thưởng/phạt và cập nhật BangLuong cùng lúc 
-- Giải thích : xử lý từng phần 
create or alter procedure sp_ThemThuongPhat_AndCapNhatBangLuong @MaNV INT,@Loai NVARCHAR(20),@SoTien DECIMAL(18,2),@LyDo NVARCHAR(200)
AS 
begin
    Set nocount on;
    Begin try
        begin transaction;
            insert into ThuongPhat(MaNV,Loai,SoTien,LyDo)
            Values(@MaNV,@Loai,@SoTien,@LyDo);

            -- update BangLuong cho ky hien tai (nam/thang hien tai)
            Update BangLuong
            Set TongThuongPhat =
                isnull(TongThuongPhat,0) + case when @Loai = N'Thưởng'
            Then @SoTien 
            else -@SoTien 
            
        end

            commit transaction;
            print N'Hoàn thành thêm thưởng/phạt và cập nhật bảng lương.';
    end try

    begin catch 
            rollback transaction;
            throw;
    end catch
end
GO

-- 5.Tạo tài khoản cho nhân viên (check MaNV và username)
create or alter proc sp_TaoTaiKhoan @TenDangNhap nvarchar(50),  @MatKhau NVARCHAR(100),@MaNV INT,@Quyen NVARCHAR(20) = N'User'
AS
    Begin
        Set nocount on;
        if not exists (select 1
                       from NhanVien
                       Where MaNv=@MaNV)
            begin 
                raiserror (N'Nhân viên không tồn tại',16,1);
                return ;
            end
        if exists (select 1
                    from TaiKhoan
                    where TenDangNhap=@TenDangNhap)
            begin 
                raiserror (N'Tên đăng nhập đã tồn tại',16,1);
                return ;
            end
        Insert into TaiKhoan(TenDangNhap,MatKhau,MaNV,Quyen)
        Values(@TenDangNhap,@MatKhau,@MaNV,@Quyen);

        print N'Tạo tài khoản cho MaNV= ' + Cast(@MaNV AS nvarchar);
    End
GO

-- 2.Function (Hàm người dùng tự tạo)

-- 2.Tổng phạt (âm) và thưởng (dương) của nhân viên
CREATE OR ALTER FUNCTION fn_TongThuongPhat_NV(@MaNV INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    SELECT @Tong = SUM(CASE WHEN Loai = N'Thưởng' THEN SoTien WHEN Loai = N'Phạt' THEN -SoTien END) 
    FROM ThuongPhat WHERE MaNV = @MaNV;
    RETURN ISNULL(@Tong,0);
END;
GO

-- 3.Tính tổng giờ tăng ca trong 1 tháng
CREATE OR ALTER FUNCTION fn_TongGioTangCa_Thang(@MaNV INT, @Thang INT, @Nam INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(10,2);
    SELECT @Tong = SUM(GioTangCa) FROM BangChamCong 
    WHERE MaNV = @MaNV AND MONTH(Ngay) = @Thang AND YEAR(Ngay) = @Nam;
    RETURN ISNULL(@Tong,0);
END;
GO

-- 4.Lấy lương cơ bản hiện tại cho nhân viên (từ HopDong nếu có, ngược lại từ LuongCoban)
CREATE OR ALTER FUNCTION fn_LayLuongCoBan_NV(@MaNV INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Luong DECIMAL(18,2);
    SELECT TOP 1 @Luong = hd.LuongCoBan
    FROM HopDong hd
    WHERE hd.MaNV = @MaNV
    ORDER BY hd.NgayBatDau DESC;

    IF @Luong IS NULL
    BEGIN
        SELECT @Luong = lcb.MucLuong FROM NhanVien nv
        LEFT JOIN LuongCoban lcb ON nv.MaCV = lcb.MaCV
        WHERE nv.MaNV = @MaNV;
    END

    RETURN ISNULL(@Luong,0);
END;
GO

-- 5.Hàm tính LươngThucNhan từ các tham số (giống cột tính toán)
CREATE OR ALTER FUNCTION fn_TinhLuongThucNhan(
    @LuongCoBan DECIMAL(18,2),
    @TongPhuCap DECIMAL(18,2),
    @TongThuongPhat DECIMAL(18,2),
    @TongGioTangCa DECIMAL(10,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN ISNULL(@LuongCoBan,0) + ISNULL(@TongPhuCap,0) + ISNULL(@TongThuongPhat,0) + ISNULL(@TongGioTangCa,0) * 50000;
END;
GO


-- 3.Trigger
-- 1.Khi có bản ghi ThuongPhat mới: cộng vào BangLuong cho kỳ hiện tại
CREATE OR ALTER TRIGGER trg_AfterInsert_ThuongPhat
ON ThuongPhat
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE bl
    SET TongThuongPhat = ISNULL(bl.TongThuongPhat,0) + ISNULL(s.AddValue,0)
    FROM BangLuong bl
    JOIN (
        SELECT i.MaNV, SUM(CASE WHEN i.Loai = N'Thưởng' THEN i.SoTien WHEN i.Loai = N'Phạt' THEN -i.SoTien END) AS AddValue
        FROM inserted i
        GROUP BY i.MaNV
    ) s ON bl.MaNV = s.MaNV
    WHERE bl.Thang = MONTH(GETDATE()) AND bl.Nam = YEAR(GETDATE());
END;
GO

-- 2.Ngăn chặn chấm công trùng ngày cho cùng 1 nhân viên (AFTER INSERT)
CREATE OR ALTER TRIGGER trg_PreventDuplicate_ChanCong
ON BangChamCong
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM BangChamCong c
        JOIN inserted i ON c.MaNV = i.MaNV AND c.Ngay = i.Ngay
        GROUP BY c.MaNV, c.Ngay
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'Phát hiện chấm công trùng ngày cho cùng 1 nhân viên.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 4.Khi xóa NhanVien — ghi log (tạo bảng log nếu chưa có)
IF OBJECT_ID('dbo.LichSuXoaNhanVien') IS NULL
BEGIN
    CREATE TABLE LichSuXoaNhanVien(
        ID INT IDENTITY(1,1) PRIMARY KEY,
        MaNV INT,
        HoTen NVARCHAR(40),
        NgayXoa DATETIME,
        LyDo NVARCHAR(200)
    );
END
GO

CREATE OR ALTER TRIGGER trg_Log_Delete_NhanVien
ON NhanVien
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO LichSuXoaNhanVien(MaNV, HoTen, NgayXoa, LyDo)
    SELECT d.MaNV, d.HoTen, GETDATE(), N'Xóa nhân viên'
    FROM deleted d;
END;
GO

-- 5.Khi thêm NhanVien — tự động tạo 1 bản BangLuong cho kỳ hiện tại với giá trị bù trống
--CREATE OR ALTER TRIGGER trg_AfterInsert_NhanVien_CreateBangLuong
--ON NhanVien
--AFTER INSERT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
--    SELECT i.MaNV, MONTH(GETDATE()), YEAR(GETDATE()), 0, 0, 0, 0
--    FROM inserted

--Phần của Scu

--------------------------------------------------
-- BẮT ĐẦU KHỐI GỘP --
--------------------------------------------------

-- PHUC : PHAN C (Từ HEAD) --
-- 1.sp_ThemHopDong: Thêm hợp đồng mới --
create procedure sp_ThemHopDong @MaNV int,@NgayBatDau date ,@NgayKetThuc date = null , @LoaiHD nvarchar(50), @Luongcoban decimal(18,2), @Ghichu nvarchar(200) = null
AS 
    Begin 
        Set nocount on;
        if exists (select 1 from HopDong 
                    Where MaNV = @MaNV
                    And(NgayKetThuc is not null and NgayKetThuc > GETDATE())OR LoaiHD = N'Không thời hạn') 
                Begin
                    Raiserror(N'Nhân viên này đang có hợp đồng còn hiệu lực!',16,1);
                    return ;
                End

                Insert into HopDong(MaNV,NgayBatDau,NgayKetThuc,LoaiHD,LuongCoBan,GhiChu)
                Values (@MaNV,@NgayBatDau,@NgayKetThuc,@LoaiHD,@Luongcoban,@Ghichu);
    end 
GO

--3.sp_ThemPhuCap: Thêm phụ cấp cho nhân viên
Create or alter procedure sp_ThemPhuCap @MaNV INT,@LoaiPhuCap NVARCHAR(50),@SoTien DECIMAL(18,2)
AS
    Begin
        Set nocount on;
        If not exists (
            select *
            from NHANVIEN
            where MANV = @MaNV
        )
        begin 
            raiserror(N'Nhân viên không tồn tại!',16,1);
            return ;
        end

        insert into PhuCap(MaNV,LoaiPhuCap,SoTien)
        Values(@MaNV,@LoaiPhuCap,@SoTien);

        print N'Đã thêm phụ cấp cho MaNV= ' + Cast(@MaNV AS nvarchar);
    End
GO

-- Tổng phụ cấp của nhân viên (all)
create or alter function fn_TongPhuCap_NV(@MaNV int)
returns decimal(18,2)
AS  
    begin
        Declare @Tong decimal(18,2);
        select @Tong = Sum(SoTien)
        from PhuCap
        where MaNV = @MaNV;

        return isnull(@Tong,0)
    end
GO

--1. Quản lí mức lương cơ bản
create procedure sp_QuanLyLuongCoBan @HanhDong nvarchar(10),@MaCV int,@MucLuong decimal(18,2) = null
AS
	Begin
		Set nocount on;
		Begin try
			begin transaction;

			if @HanhDong = 'Thêm'
				Insert into LuongCoBan(MaCV,MucLuong)
				values (@MaCV,@MucLuong);
			else if @HanhDong = 'Sửa'
				Update LuongCoBan Set MucLuong = @MucLuong 
				where MaCV = @MaCV;
			else if @HanhDong = 'Xóa'
				Delete From LuongCoBan 
				where MaCV = @MaCV;
			else
				Raiserror(N'Hành động không hợp lệ! Chỉ được dùng Thêm/Sửa/Xóa.',16,1);
			
			Commit transaction ;
		End try
		Begin Catch
			Rollback Transaction;
			Declare @Loi nvarchar(4000) = ERROR_MESSAGE();
			Raiserror(@Loi,16,1);
		End Catch
	End
GO

-- 2 . sp_CapNhatTrangThaiNV : khi nhân viên không có hợp đồng còn hiệu lực thì tự động set "Nghỉ việc"
create or alter procedure sp_CapNhatTrangThaiNV
AS
Begin
    Set nocount on;
    Update NhanVien
    Set TrangThai = N'Nghỉ việc'
    Where MaNV Not in (
        Select MaNV From HopDong
        Where(NgayKetThuc is null or NgayKetThuc>GETDATE())
        );
End
GO

-- 4. sp_DanhSachHopDongNV : liệt kê hợp đồng theo nhân viên,loại hợp đồng,thời hạn.
create procedure sp_DanhSachHopDongNV @MaNV int = null
as
begin 
    set nocount on;
    select * from HopDong
    where @MaNV is null or MaNV = @MaNV;
end
GO

-- 5. sp_TongPhuCapTheoLoai : tổng phụ cấp theo loại cho toàn bộ nhân viên,hỗ trợ phân tích
create procedure sp_TongPhuCapTheoLoai @LoaiPhuCap nvarchar(50) = null
as
begin 
    set nocount on;
    select LoaiPhuCap, sum(SoTien) as TongPhuCap
    from PhuCap
    Where @LoaiPhuCap is null or LoaiPhuCap = @LoaiPhuCap
    group by LoaiPhuCap
end
GO

-- 1.tr_HopDong_AfterUpdate: Cập nhật trạng thái hợp đồng hết hạn
create trigger tr_HopDong_AfterUpdate
On HopDong
After Update
AS
    Begin
        Set Nocount on;

        Update NhanVien
        Set TrangThai = N'Nghỉ việc'
        Where MaNV in(
        Select i.MaNV
        from inserted i
        where i.NgayKetThuc < Getdate()
        );
    End
GO

-- 2. tr_HopDong_AlterInsert: tự động cập nhật trạng thái nhân viên khi thêm hợp đồng mới
create trigger tr_HopDong_AlterInsert 
on HopDong
After insert
as
begin
    set nocount on;
    Update NhanVien
    Set TrangThai = N'Đang làm'
    where MaNV in (
        select i.MaNV
        from inserted i
        where i.NgayKetThuc is null or i.NgayKetThuc > GETDATE()
        );
end
GO

-- 3.tr_NhanVien_AfterUpdate : Thêm cột LuongHienTai và cập nhật
Alter table NhanVien
Add LuongHienTai decimal(18,2);
GO

create trigger tr_NhanVien_AfterUpdate 
on NhanVien
After Update
as
begin
    Set nocount on;

    -- cap nhat LuongHienTai khi MaCV thay doi
    Update nv
    Set nv.LuongHienTai = lc.MucLuong
    From NhanVien nv
    join inserted i on nv.MaNV = i.MaNV
  DJoin LuongCoban lc on i.MaCV = lc.MaCV
    Where i.MaCV <> (Select d.MaCV from deleted d where d.MaNV = i.MaNV);
end
GO

-- truy vấn cập nhật lương hiện tại cho các nhân viên trong db
UPDATE nv
SET nv.LuongHienTai = ISNULL(hd.LuongCoBan, lc.MucLuong)
FROM NhanVien nv
LEFT JOIN HopDong hd 
       ON nv.MaNV = hd.MaNV 
       AND (hd.NgayKetThuc IS NULL OR hd.NgayKetThuc > GETDATE())
LEFT JOIN LuongCoban lc
       ON nv.MaCV = lc.MaCV;
GO

SELECT MaNV, HoTen, MaCV, LuongHienTai
FROM NhanVien;
GO

-- 5. tr_LuongCoBan_AfterUpdate 
-- Tạo bảng Audit nếu chưa có
IF OBJECT_ID('LuongCoBanLog') IS NULL
BEGIN
    CREATE TABLE LuongCoBanLog(
        ID INT IDENTITY(1,1) PRIMARY KEY,
        MaCV INT,
        MucLuongCu DECIMAL(18,2),
        MucLuongMoi DECIMAL(18,2),
        NgayCapNhat DATETIME DEFAULT GETDATE()
    );
END
GO

CREATE TRIGGER tr_LuongCoBan_AfterUpdate
ON LuongCoBan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LuongCoBanLog(MaCV, MucLuongCu, MucLuongMoi)
    SELECT d.MaCV, d.MucLuong, i.MucLuong
    FROM inserted i
    JOIN deleted d ON i.MaCV = d.MaCV
    WHERE i.MucLuong <> d.MucLuong;
END
GO

-- 1.  fn_HopDongConHieuLuc: trả về 1/0 nếu nhân viên có hợp đồng còn hiệu lực.
create function fn_HopDongConHieuLuc(@MaNV int)
returns bit
as
begin
    declare @Kq bit;
    if exists(select 1 from HopDong where MaNV = @MaNV and (NgayKetThuc is null or NgayKetThuc > getdate()))
        set @Kq = 1;
    else
        set @Kq = 0;
    return @Kq;
end
GO

-- 2. fn_LuongTong_NV – tính tổng lương = Lương cơ bản + tổng phụ cấp của nhân viên.
create function fn_LuongTong_NV(@MaNV int)
returns decimal(18,2)
as
begin
    declare @Luong decimal(18,2);
    select @Luong = isnull((select MucLuong from LuongCoBan lc
                            join NhanVien nv on nv.MaCV = lc.MaCV
                            where nv.MaNV = @MaNV),0)
                   + dbo.fn_TongPhuCap_NV(@MaNV);
    return @Luong;
end
GO

-- 3. fn_SoLuongHopDongHetHan: Trả về số lượng hợp đồng đã hết hạn.
CREATE FUNCTION fn_SoLuongHopDongHetHan()
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;

    SELECT @SoLuong = COUNT(*)
    FROM HopDong
    WHERE NgayKetThuc IS NOT NULL
      AND NgayKetThuc < GETDATE();

    RETURN ISNULL(@SoLuong, 0);
END
GO

-- 4. fn_TongPhuCapLoai: Trả về tổng phụ cấp theo loại, có thể dùng để báo cáo.
CREATE FUNCTION fn_TongPhuCapLoai(@LoaiPhuCap NVARCHAR(50) = NULL)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);

    SELECT @Tong = SUM(SoTien)
    FROM PhuCap
    WHERE @LoaiPhuCap IS NULL OR LoaiPhuCap = @LoaiPhuCap;

    RETURN ISNULL(@Tong, 0);
END
GO

-- PHẦN CỦA SCU (Từ origin/Scu) --
-- 1: Thêm nhân viên mới
CREATE OR ALTER PROCEDURE sp_ThemNhanVien
    @HoTen NVARCHAR(40),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(5),
    @DiaChi NVARCHAR(50),
    @DienThoai NVARCHAR(15),
    @Email NVARCHAR(60) = NULL,
    @MaPB INT = NULL,
    @MaCV INT = NULL
AS
BEGIN
    IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM NhanVien WHERE Email = @Email)
    BEGIN
        RAISERROR(N'Email đã tồn tại!',16,1);
        RETURN;
    END

    INSERT INTO NhanVien(HoTen, NgaySinh, GioiTinh, DiaChi, DienThoai, Email, MaPB, MaCV)
    VALUES(@HoTen, @NgaySinh, @GioiTinh, @DiaChi, @DienThoai, @Email, @MaPB, @MaCV);

    PRINT N'Đã thêm nhân viên mới thành công!';
END;
GO

-- 2: Xóa nhân viên (gọi trigger ghi log)
CREATE PROCEDURE sp_DeleteNhanVien
    @MaNV NVARCHAR(10)
AS
BEGIN
    DELETE FROM NhanVien WHERE MaNV = @MaNV
END
GO

-- 3: Tạo tài khoản cho nhân viên
CREATE OR ALTER PROCEDURE sp_TaoTaiKhoan
    @MaNV INT,
    @TenDangNhap NVARCHAR(50),
    @MatKhau NVARCHAR(100),
    @Quyen NVARCHAR(20) = N'User'
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM NhanVien WHERE MaNV = @MaNV)
    BEGIN
        RAISERROR(N'Không tồn tại nhân viên này!',16,1);
        RETURN;
    END

    IF EXISTS(SELECT 1 FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap)
    BEGIN
        RAISERROR(N'Tên đăng nhập đã tồn tại!',16,1);
        RETURN;
    END

    INSERT INTO TaiKhoan(MaNV, TenDangNhap, MatKhau, Quyen)
    VALUES(@MaNV, @TenDangNhap, @MatKhau, @Quyen);

    PRINT N'Đã tạo tài khoản cho nhân viên thành công!';
END;
GO


-- 4: Quản lý phòng ban (Thêm / Sửa / Xóa)
CREATE OR ALTER PROCEDURE sp_QuanLyPhongBan
    @ThaoTac NVARCHAR(10),  -- 'THEM', 'SUA', 'XOA'
    @MaPB INT = NULL,
    @TenPB NVARCHAR(50) = NULL
AS
BEGIN
    IF @ThaoTac = 'THEM'
        INSERT INTO PhongBan(TenPB) VALUES(@TenPB);

    ELSE IF @ThaoTac = 'SUA'
        UPDATE PhongBan SET TenPB = @TenPB WHERE MaPB = @MaPB;

    ELSE IF @ThaoTac = 'XOA'
        DELETE FROM PhongBan WHERE MaPB = @MaPB;

    ELSE
        RAISERROR(N'Thao tác không hợp lệ (THEM/SUA/XOA)!',16,1);

    PRINT N'Đã thực hiện quản lý phòng ban thành công!';
END;
GO


-- 5: Quản lý chức vụ và hệ số lương (Thêm / Sửa / Xóa)
CREATE OR ALTER PROCEDURE sp_QuanLyChucVu
    @ThaoTac NVARCHAR(10),
    @MaCV INT = NULL,
    @TenCV NVARCHAR(50) = NULL,
    @HeSoLuong DECIMAL(4,2) = NULL
AS
BEGIN
    IF @ThaoTac = 'THEM'
        INSERT INTO ChucVu(TenCV, HeSoLuong) VALUES(@TenCV, @HeSoLuong);

    ELSE IF @ThaoTac = 'SUA'
        UPDATE ChucVu SET TenCV = @TenCV, HeSoLuong = @HeSoLuong WHERE MaCV = @MaCV;

    ELSE IF @ThaoTac = 'XOA'
        DELETE FROM ChucVu WHERE MaCV = @MaCV;

    ELSE
        RAISERROR(N'Thao tác không hợp lệ (THEM/SUA/XOA)!',16,1);

    PRINT N'Đã thực hiện quản lý chức vụ thành công!';
END;
GO

-- 2️ TRIGGER (Từ origin/Scu) --
-- 1: Khi thêm nhân viên → tự tạo bảng lương
CREATE OR ALTER TRIGGER trg_TaoBangLuongKhiThemNV
ON NhanVien
AFTER INSERT
AS
BEGIN
    INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
    SELECT MaNV, MONTH(GETDATE()), YEAR(GETDATE()), 0, 0, 0, 0
    FROM inserted;
    PRINT N'Đã tự tạo bảng lương cho nhân viên mới!';
END;
GO


-- 2: Khi xóa nhân viên → ghi log vào LichSuXoaNhanVien
-- (Đã tồn tại ở bản gốc, bản này giống hệt nên bỏ qua)
-- CREATE OR ALTER TRIGGER trg_Log_Delete_NhanVien ...

-- 3: Khi thêm tài khoản → log lịch sử tạo tài khoản
-- (Cần bảng LichSuTaiKhoan)
IF OBJECT_ID('dbo.LichSuTaiKhoan') IS NULL
BEGIN
	CREATE TABLE LichSuTaiKhoan(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		MaNV INT,
		TenDangNhap NVARCHAR(50),
		NgayTao DATETIME DEFAULT GETDATE()
	);
END
GO

CREATE OR ALTER TRIGGER trg_Log_TaoTaiKhoan
ON TaiKhoan
AFTER INSERT
AS
BEGIN
    INSERT INTO LichSuTaiKhoan(MaNV, TenDangNhap, NgayTao)
    SELECT MaNV, TenDangNhap, GETDATE() FROM inserted;
    PRINT N'Đã ghi log tạo tài khoản!';
END;
GO


-- 4: Khi xóa phòng ban → tự động set MaPB của nhân viên = NULL
CREATE OR ALTER TRIGGER trg_SetNull_MaPB_WhenPhongBanXoa
ON PhongBan
AFTER DELETE
AS
BEGIN
    UPDATE NhanVien
    SET MaPB = NULL
    WHERE MaPB IN (SELECT MaPB FROM deleted);
    PRINT N'Phòng ban bị xóa → cập nhật lại nhân viên!';
END;
GO


-- 5: Khi sửa hệ số lương → tự cập nhật bảng lương liên quan
CREATE OR ALTER TRIGGER trg_CapNhatLuongKhiDoiHeSo
ON ChucVu
AFTER UPDATE
AS
BEGIN
    UPDATE b
    SET b.LuongCoBan = c.HeSoLuong * 1000000 -- (Giả định 1 hệ số = 1,000,000)
    FROM BangLuong b
    INNER JOIN NhanVien n ON b.MaNV = n.MaNV
    INNER JOIN inserted c ON n.MaCV = c.MaCV;
    PRINT N'Đã cập nhật lương cơ bản khi thay đổi hệ số!';
END;
GO


-- 3️ FUNCTION (Từ origin/Scu) --
-- 1: Lấy mã nhân viên theo email
CREATE OR ALTER FUNCTION fn_LayMaNhanVienTheoEmail(@Email NVARCHAR(60))
RETURNS INT
AS
BEGIN
    DECLARE @MaNV INT;
    SELECT TOP 1 @MaNV = MaNV FROM NhanVien WHERE Email = @Email;
    RETURN ISNULL(@MaNV, 0);
END;
GO


-- 2: Kiểm tra xem nhân viên có tồn tại trước khi xóa
CREATE OR ALTER FUNCTION fn_KiemTraNhanVienTonTai(@MaNV INT)
RETURNS BIT
AS
BEGIN
    RETURN (SELECT CASE WHEN EXISTS(SELECT 1 FROM NhanVien WHERE MaNV = @MaNV) THEN 1 ELSE 0 END);
END;
GO


-- 3: Lấy quyền của tài khoản
CREATE OR ALTER FUNCTION fn_LayQuyenTaiKhoan(@TenDangNhap NVARCHAR(50))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Quyen NVARCHAR(20);
    SELECT @Quyen = Quyen FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap;
    RETURN ISNULL(@Quyen, N'User');
END;
GO


-- 4: Đếm số nhân viên trong phòng ban
CREATE OR ALTER FUNCTION fn_DemNhanVienTrongPhong(@MaPB INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM NhanVien WHERE MaPB = @MaPB);
END;
GO


-- 5: Tính trung bình hệ số lương các chức vụ
CREATE OR ALTER FUNCTION fn_TrungBinhHeSoLuong()
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN (SELECT AVG(HeSoLuong) FROM ChucVu);
END;
GO

--------------------------------------------------
-- KẾT THÚC KHỐI GỘP --
--------------------------------------------------

--Chương 3 lưu trữ (Từ origin/Scu)
BACKUP DATABASE QL_LuongNV
TO DISK = 'D:\code\DoAnHQT_SQL\QL_LuongNV_Full.bak'
WITH FORMAT, INIT,
     NAME = 'Full Backup of QL_LuongNV',
     SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

CREATE OR ALTER PROCEDURE sp_TaoBackup_QLLuong
AS
BEGIN
    DECLARE @File NVARCHAR(300);

    -- Tạo tên file dạng QL_Luong_YYYYMMDD_HHMMSS.bak
    SET @File = 'D:\Backup_QLLuong\QL_Luong_' 
                + CONVERT(VARCHAR(8), GETDATE(), 112) + '_' 
                + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '') + '.bak';

    BACKUP DATABASE QL_LuongNV
    TO DISK = @File
    WITH INIT, FORMAT,
         NAME = 'Backup tu dong CSDL QL_Luong',
         SKIP, NOREWIND, NOUNLOAD, STATS = 10;
END;
GO
--EXEC sp_TaoBackup_QLLuong;
--Xóa tự động các file cũ ( giữ lại 7 ngày gần nhất)
EXEC xp_cmdshell 'forfiles /p "D:\code\DoAnHQT_SQL" /s /m *.bak /d -7 /c "cmd /c del @path"';
GO

--Khôi phục csdl khi có sự cố 
--USE master;
--RESTORE DATABASE QL_LuongNV
--FROM DISK = 'D:\code\DoAnHQT_SQL\QL_LuongNV_Full.bak'
--WITH REPLACE;
--GO
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

--ALTER DATABASE QL_LuongNV SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--DROP DATABASE QL_LuongNV;
