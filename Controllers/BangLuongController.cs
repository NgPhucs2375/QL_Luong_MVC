using QL_Luong_MVC.DAO;
using System;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    /// <summary>
    /// Controller quản lý bảng lương
    /// Chức năng: UC13 (Tính lương tháng), UC20 (Xem báo cáo lương)
    /// </summary>
    public class BangLuongController : Controller
    {
        // Khởi tạo DAO để truy cập database
        private readonly BangLuongDAO bangLuongDAO = new BangLuongDAO();

        // ==================================================================================
        // UC20: HIỂN THỊ DANH SÁCH BẢNG LƯƠNG
        // ==================================================================================

        /// <summary>
        /// [UC20] Trang chủ - Hiển thị danh sách bảng lương
        /// Route: /BangLuong/Index
        /// </summary>
        public ActionResult Index(int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                // Lấy danh sách bảng lương theo tháng/năm
                var danhSach = bangLuongDAO.GetByThang(thangHienTai, namHienTai);

                // Truyền tháng/năm sang View
                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;

                return View(danhSach);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải danh sách bảng lương: " + ex.Message;
                return View();
            }
        }

        // ==================================================================================
        // UC13: TÍNH BẢNG LƯƠNG THEO THÁNG
        // ==================================================================================

        /// <summary>
        /// [UC13] Hiển thị form chọn tháng/năm để tính lương
        /// Route: GET /BangLuong/TinhLuong
        /// </summary>
        [HttpGet]
        public ActionResult TinhLuong()
        {
            // Set mặc định là tháng/năm hiện tại
            ViewBag.ThangMacDinh = DateTime.Now.Month;
            ViewBag.NamMacDinh = DateTime.Now.Year;

            return View();
        }

        /// <summary>
        /// [UC13] Xử lý tính lương - Gọi SP sp_TinhBangLuong_Thang
        /// Route: POST /BangLuong/TinhLuong
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult TinhLuong(int thang, int nam)
        {
            try
            {
                // Kiểm tra tháng hợp lệ (1-12)
                if (thang < 1 || thang > 12)
                {
                    ViewBag.ErrorMessage = "Tháng phải từ 1 đến 12";
                    ViewBag.ThangMacDinh = DateTime.Now.Month;
                    ViewBag.NamMacDinh = DateTime.Now.Year;
                    return View();
                }

                // Kiểm tra năm hợp lệ (>= 2000)
                if (nam < 2000)
                {
                    ViewBag.ErrorMessage = "Năm phải lớn hơn hoặc bằng 2000";
                    ViewBag.ThangMacDinh = DateTime.Now.Month;
                    ViewBag.NamMacDinh = DateTime.Now.Year;
                    return View();
                }

                // Gọi DAO để tính lương (gọi SP)
                var result = bangLuongDAO.TinhBangLuongThang(thang, nam);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    // Redirect sang trang báo cáo để xem kết quả
                    return RedirectToAction("BaoCao", new { thang = thang, nam = nam });
                }
                else
                {
                    ViewBag.ErrorMessage = result.Message;
                    ViewBag.ThangMacDinh = thang;
                    ViewBag.NamMacDinh = nam;
                    return View();
                }
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                ViewBag.ThangMacDinh = thang;
                ViewBag.NamMacDinh = nam;
                return View();
            }
        }

        // ==================================================================================
        // UC20: XEM BÁO CÁO LƯƠNG THÁNG (TỔNG HỢP)
        // ==================================================================================

        /// <summary>
        /// [UC20] Xem báo cáo lương tổng hợp với thông tin đầy đủ
        /// Route: /BangLuong/BaoCao?thang={thang}&nam={nam}
        /// </summary>
        public ActionResult BaoCao(int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                // Lấy báo cáo lương tổng hợp (JOIN với NhanVien, ChucVu, PhongBan)
                var baoCao = bangLuongDAO.GetBaoCaoLuongThang(thangHienTai, namHienTai);

                // Truyền thông tin sang View
                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;
                ViewBag.TongSoNhanVien = baoCao.Count;

                // Tính tổng lương phải trả trong tháng
                decimal tongLuongThang = 0;
                foreach (var item in baoCao)
                {
                    tongLuongThang += item.LuongThucNhan_BaoCao;
                }
                ViewBag.TongLuongThang = tongLuongThang;

                return View(baoCao);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải báo cáo: " + ex.Message;
                return View();
            }
        }

        // ==================================================================================
        // UC20: XEM CHI TIẾT LƯƠNG CỦA 1 NHÂN VIÊN
        // ==================================================================================

        /// <summary>
        /// [UC20] Xem lịch sử lương của 1 nhân viên
        /// Route: /BangLuong/ChiTietNhanVien/{maNV}
        /// </summary>
        public ActionResult ChiTietNhanVien(int maNV)
        {
            try
            {
                // Lấy lịch sử lương của nhân viên
                var lichSuLuong = bangLuongDAO.GetByNhanVien(maNV);

                ViewBag.MaNhanVien = maNV;

                return View(lichSuLuong);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải lịch sử lương: " + ex.Message;
                return View();
            }
        }

        // ==================================================================================
        // HELPER: EXPORT BÁO CÁO RA EXCEL (OPTIONAL - CÓ THỂ BỔ SUNG SAU)
        // ==================================================================================

        /// <summary>
        /// [UC20] Export báo cáo lương ra file Excel (Optional)
        /// Route: /BangLuong/ExportExcel?thang={thang}&nam={nam}
        /// </summary>
        public ActionResult ExportExcel(int? thang, int? nam)
        {
            try
            {
                // TODO: Implement export Excel logic
                // Sử dụng thư viện như EPPlus hoặc ClosedXML

                TempData["InfoMessage"] = "Chức năng Export Excel đang được phát triển";
                return RedirectToAction("BaoCao", new { thang = thang, nam = nam });
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi export: " + ex.Message;
                return RedirectToAction("BaoCao", new { thang = thang, nam = nam });
            }
        }
    }
}
