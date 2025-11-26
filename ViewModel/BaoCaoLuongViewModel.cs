using System;

namespace QL_Luong_MVC.ViewModel
{
    /// <summary>
    /// ViewModel cho báo cáo lương tổng hợp (UC20)
    /// Chứa thông tin đầy đủ từ nhiều bảng: NhanVien, ChucVu, PhongBan, BangLuong
    /// </summary>
    public class BaoCaoLuongViewModel
    {
        // ==================================================================================
        // THÔNG TIN NHÂN VIÊN
        // ==================================================================================

        /// <summary>
        /// Mã nhân viên (từ bảng NhanVien)
        /// </summary>
        public int MaNhanVien_BaoCao { get; set; }

        /// <summary>
        /// Họ tên nhân viên (từ bảng NhanVien)
        /// </summary>
        public string HoTenNhanVien_BaoCao { get; set; }

        /// <summary>
        /// Tên chức vụ (từ bảng ChucVu)
        /// </summary>
        public string TenChucVu_BaoCao { get; set; }

        /// <summary>
        /// Tên phòng ban (từ bảng PhongBan)
        /// </summary>
        public string TenPhongBan_BaoCao { get; set; }

        // ==================================================================================
        // THÔNG TIN THỜI GIAN
        // ==================================================================================

        /// <summary>
        /// Tháng tính lương (1-12)
        /// </summary>
        public int Thang_BaoCao { get; set; }

        /// <summary>
        /// Năm tính lương (VD: 2025)
        /// </summary>
        public int Nam_BaoCao { get; set; }

        // ==================================================================================
        // CÁC THÀNH PHẦN LƯƠNG
        // ==================================================================================

        /// <summary>
        /// Lương cơ bản (từ Hợp đồng hoặc Chức vụ)
        /// </summary>
        public decimal LuongCoBan_BaoCao { get; set; }

        /// <summary>
        /// Tổng phụ cấp (xăng xe, điện thoại, ăn trưa, v.v.)
        /// </summary>
        public decimal TongPhuCap_BaoCao { get; set; }

        /// <summary>
        /// Tổng thưởng/phạt (Thưởng = +, Phạt = -)
        /// </summary>
        public decimal TongThuongPhat_BaoCao { get; set; }

        /// <summary>
        /// Tổng giờ tăng ca trong tháng
        /// </summary>
        public decimal TongGioTangCa_BaoCao { get; set; }

        /// <summary>
        /// Lương thực nhận (Computed Column)
        /// Công thức: LuongCoBan + TongPhuCap + TongThuongPhat + (TongGioTangCa × 50,000)
        /// </summary>
        public decimal LuongThucNhan_BaoCao { get; set; }

        // ==================================================================================
        // THUỘC TÍNH TÍNH TOÁN BỔ SUNG (OPTIONAL)
        // ==================================================================================

        /// <summary>
        /// Tính tiền lương tăng ca (50,000 VNĐ/giờ)
        /// </summary>
        public decimal TienTangCa_BaoCao
        {
            get { return TongGioTangCa_BaoCao * 50000; }
        }

        /// <summary>
        /// Định dạng tháng/năm để hiển thị (VD: "11/2025")
        /// </summary>
        public string ThangNam_BaoCao
        {
            get { return $"{Thang_BaoCao:D2}/{Nam_BaoCao}"; }
        }
    }
}
