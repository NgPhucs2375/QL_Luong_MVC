create database QL_LuongNV
use QL_LuongNV

-- ================================================
-- CHƯƠNG 1: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ LƯƠNG
-- ================================================

--!Tên CSDL : QL_LuongNV !--
--!MỤC TIÊU : Quản lí thông tin nhân viên,phòng ban,chức vụ, bảng lương, chấm công, phục cấp, thưởng phạt,hợp đồng, và tính toán lưng thực hận hàng tháng !--

--!Các bảng chính (khoảng 10 bảng )
--!Tên Bảng : 1.PhongBan {Quản lý thông tin các phòng ban}
--!         : 2.ChucVu {Danh mục chức vụ và hệ số lương}
--!         : 3.NhanVien {Lưu thông tin nhân viên} 
--!         : 4.HopDong {Quản lý hợp đồng lao động}
--!         : 5.ChamCong {Ghi nhận ngày công, giờ tăng ca}
--!         : 6.LuongCoBan {Mức lương cơ bản theo từng chức vụ} 
--!         : 7.PhuCap {Các khoản phụ cấp theo nhân viên} 
--!         : 8.ThuongPhat {Thưởng và phạt theo tháng} 
--!         : 9.BangLuong {Bảng tổng hợp lương hàng tháng}
--!         : 10.TaiKhoan {Quản lý tài khoản đăng nhập hệ thống (nếu có phần mềm quản lý)}

--!======================================================================
--!                                 BẢNG                              !--
--!======================================================================



create table PhongBan
(
	MaPB int identity(1,1) not null primary key,
	TenPB nvarchar(50) not null Unique,
	NgayThanhLap Date Default GetDate()
)

create table ChucVu
(
	MaCV int identity(1,1) not null primary key,
	TenCV nvarchar(50) not null unique,
	HeSoLuong Decimal(4,2) Check(HeSoLuong BETWEEN 1 AND 10)
)

create table NhanVien
(
	MaNV int identity(1,1) not null primary key,
	HoTen nvarchar(40) not null,
	NgaySinh Date Check(NgaySinh <GetDate()),
	GioiTinh  nvarchar(5) DEFAULT N'Nam',
	DiaChi nvarchar(50),
	DienThoai nvarchar(15),
	Email nvarchar(60) unique,
	TrangThai nvarchar(25) DEFAULT N'Đang làm',
	MaCV int ,
	MaPB int ,
	constraint FK_MaCV_NhanVien foreign key (MaCV) references  ChucVu(MaCV),
	constraint FK_MaPB_NhanVien foreign key (MaPB) references  PhongBan(MaPB),

)

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

create table BangChamCong
(
	MaCC int identity(1,1) not null primary key,
	MaNV int,
	Ngay Date not null,
	NgayCong decimal(4,2) default 1.0 check(NgayCong BETWEEN 0 AND 1),
	GioTangCa decimal(5,2) default 0 check (GioTangCa >= 0),
	constraint FK_MaNV_BangChamCong foreign key (MaNV) references NhanVien(MaNV)
)

create table PhuCap
(
	MaPC int identity(1,1) not null primary key,
	MaNV int ,
	LoaiPhuCap nvarchar(50),
	SoTien decimal(18,2) check(SoTien>=0),
	constraint FK_MaNV_PhuCap foreign key (MaNV) references NhanVien(MaNV)
)

create table ThuongPhat
(
	MaTP int identity(1,1) not null primary key,
	MaNV int ,
	Loai nvarchar(20) check (Loai in(N'Thưởng',N'Phạt')),
	SoTien decimal(18,2) check(SoTien>0),
	LyDo nvarchar(200),
	constraint FK_MaNV_ThuongPhat foreign key (MaNV) references NhanVien(MaNV)
)

create table LuongCoban
(
	MaLCB int identity(1,1) not null primary key,
	MaCV int,
	MucLuong decimal(18,2) check (MucLuong>0),
	constraint Fk_MaCV_LuongCoBan foreign key (MaCV) references ChucVu(MaCV)
)

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

create table TaiKhoan
(
	TenDangNhap nvarchar(50) not null primary key,
	MatKhau nvarchar(100) not null,
	MaNV int ,
	Quyen nvarchar(20) default N'User',
	constraint FK_MaNV_TaiKhoan foreign key (MaNV) references NhanVien(MaNV)
)


-- ========================
-- DỮ LIỆU MẪU
-- ========================

Insert into PhongBan(TenPB)
Values(N'Phòng Nhân Sự'),
(N'Phòng Kế Toán'),
(N'Phòng IT'),
(N'Phòng Kinh Doanh'),
(N'Phòng Marketing'),
(N'Phòng Hành Chính');

Insert into ChucVu(TenCV,HeSoLuong)
Values(N'Nhân viên',1.20),
(N'Trưởng phòng',2.00),
(N'Giám đốc',3.50),
(N'Phó phòng', 1.70),
(N'Kế toán trưởng', 2.20);

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

INSERT INTO ThuongPhat(MaNV, Loai, SoTien, LyDo)
VALUES
(1, N'Thưởng', 1000000, N'Hoàn thành tốt công việc'),
(2, N'Phạt', 300000, N'Đi muộn'),
(3, N'Thưởng', 2000000, N'Dự án xuất sắc'),
(4, N'Thưởng', 500000, N'Đạt chỉ tiêu tháng'),
(5, N'Phạt', 200000, N'Nghỉ không phép'),
(6, N'Thưởng', 1000000, N'Ý tưởng sáng tạo'),
(7, N'Thưởng', 800000, N'Hỗ trợ nhóm tốt'),
(8, N'Phạt', 300000, N'Đi muộn 2 lần'),
(9, N'Thưởng', 1500000, N'Quản lý xuất sắc');

INSERT INTO LuongCoBan(MaCV, MucLuong)
VALUES
(1, 8000000),
(2, 12000000),
(3, 20000000),
(4, 10000000),
(5, 13000000);


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





-- ================================================
--         CHƯƠNG 2: CÀI ĐẶT YÊU CẦU XỬ LÝ
-- ================================================

-- Mục tiêu : Tạo dựng cài đặt yêu cầu xử lý cho dữ liệu được đặt ra
-- 1.Procedure :
-- 2.Function :
-- 3.Trigger :
-- 4.Cursor :
-- 5.Transaction :

--!======================================================================
--!                                 Yêu cầu                           !--
--!======================================================================

-- 1.Procedure (Thủ tục)

-- 1.Thêm nhân viên mới (check email có trùng lặp hay không)
-- Giải thích: dùng cột hiện có, tránh chèn vào cột không tồn tại.
create procedure sp_AddNhanVien  @HoTen NVARCHAR(40),@NgaySinh DATE,@GioiTinh NVARCHAR(5),@DiaChi NVARCHAR(50),@DienThoai NVARCHAR(15),@Email NVARCHAR(60),@MaPB INT,@MaCV INT
AS
	Begin 
		Set Nocount on;
		If @Email is not null and exists 
			(
				Select * 
				from NhanVien 
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

-- 3.Thêm phụ cấp cho 1 nhân viên 
-- 
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
			raiserror(N'Cannot find a staff',16,1);
			return ;
		end

		insert into PhuCap(MaNV,LoaiPhuCap,SoTien)
		Values(@MaNV,@LoaiPhuCap,@SoTien);

		print N'Đã thêm phụ cấp cho MaNV= ' + Cast(@MaNV AS nvarchar);
	End

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

-- 5.Tạo tài khoản cho nhân viên (check MaNV và username)
create or alter proc sp_TaoTaiKhoan @TenDangNhap nvarchar(50),  @MatKhau NVARCHAR(100),@MaNV INT,@Quyen NVARCHAR(20) = N'User'
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

-- 2.Function (Hàm người dùng tự tạo)
-- 1.Tổng phụ cấp của nhân viên (all)
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

-- 3.Khi cập nhật HopDong — nếu NgayKetThuc < GETDATE() thì cập nhật NhanVien.TrangThai = 'Nghỉ việc'
CREATE OR ALTER TRIGGER trg_HopDong_AfterUpdate
ON HopDong
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE nv
    SET TrangThai = N'Ngỉ việc'
    FROM NhanVien nv
    JOIN inserted i ON nv.MaNV = i.MaNV
    WHERE i.NgayKetThuc IS NOT NULL AND i.NgayKetThuc < GETDATE();
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
--    SET NOCOUNT ON;

--    INSERT INTO BangLuong(MaNV, Thang, Nam, LuongCoBan, TongPhuCap, TongThuongPhat, TongGioTangCa)
--    SELECT i.MaNV, MONTH(GETDATE()), YEAR(GETDATE()), 0, 0, 0, 0
--    FROM inserted
