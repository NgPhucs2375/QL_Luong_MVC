using QL_Luong_MVC.DAO;
using System;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class BangLuongController : Controller
    {
        // Khởi tạo DAO để truy cập database
        private readonly BangLuongDAO bangLuongDAO = new BangLuongDAO();

        [CustomAuthorize(Roles = "Admin,KeToan")]
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


        [HttpGet]

        public ActionResult TinhLuong()
        {
            // Set mặc định là tháng/năm hiện tại
            ViewBag.ThangMacDinh = DateTime.Now.Month;
            ViewBag.NamMacDinh = DateTime.Now.Year;

            return View();
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        [CustomAuthorize(Roles = "Admin,KeToan")]
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

        [CustomAuthorize(Roles = "Admin,KeToan")]
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

        [CustomAuthorize]
        public ActionResult ChiTietNhanVien(int maNV)
        {
           try
            {  int currentID = Convert.ToInt32(Session["MaNV"]);
            string currentRole = Session["Quyen"].ToString();
            if (currentRole == "User" && currentID != maNV)
            {
                TempData["Error"] = "Bạn chỉ được xem phiếu lương của chính mình!";
                return RedirectToAction("ChiTietNhanVien", new { maNV = currentID });
            }
           
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


        public ActionResult ExportExcel(int? thang, int? nam)
        {
            try
            {
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
