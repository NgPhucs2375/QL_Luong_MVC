using QL_Luong_MVC.DAO;
using System;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class BangLuongController : Controller
    {
        private readonly BangLuongDAO bangLuongDAO = new BangLuongDAO();

        [CustomAuthorize(Roles = "Admin,KeToan")]
        public ActionResult Index(int? thang, int? nam)
        {
            try
            {
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                var danhSach = bangLuongDAO.GetByThang(thangHienTai, namHienTai);

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


        [CustomAuthorize(Roles = "Admin,KeToan")]
        public ActionResult ExportExcel(int? thang, int? nam)
        {
            try
            {
                int t = thang ?? DateTime.Now.Month;
                int n = nam ?? DateTime.Now.Year;

                // 1. Lấy dữ liệu báo cáo
                var data = bangLuongDAO.GetBaoCaoLuongThang(t, n);

                if (data == null || data.Count == 0)
                {
                    TempData["ErrorMessage"] = $"Không có dữ liệu lương tháng {t}/{n} để xuất file.";
                    return RedirectToAction("BaoCao", new { thang = t, nam = n });
                }

                // 2. Xây dựng nội dung file CSV (Dùng StringBuilder)
                var sb = new System.Text.StringBuilder();

                // -- Header cột --
                sb.AppendLine("Mã NV,Họ Tên,Phòng Ban,Chức Vụ,Lương Cơ Bản,Phụ Cấp,Thưởng/Phạt,Giờ Tăng Ca,Thành Tiền TC,THỰC LĨNH");

                // -- Dữ liệu dòng --
                foreach (var item in data)
                {
                    // Định dạng số tiền bỏ dấu phẩy để tránh lỗi CSV
                    var luongCB = item.LuongCoBan_BaoCao.ToString("0");
                    var phuCap = item.TongPhuCap_BaoCao.ToString("0");
                    var thuongPhat = item.TongThuongPhat_BaoCao.ToString("0");
                    var tangCaTien = item.TienTangCa_BaoCao.ToString("0");
                    var thucLinh = item.LuongThucNhan_BaoCao.ToString("0");

                    // Nối chuỗi, lưu ý bọc tên có dấu phẩy trong ngoặc kép nếu cần
                    sb.AppendLine($"{item.MaNhanVien_BaoCao},{item.HoTenNhanVien_BaoCao},{item.TenPhongBan_BaoCao},{item.TenChucVu_BaoCao},{luongCB},{phuCap},{thuongPhat},{item.TongGioTangCa_BaoCao},{tangCaTien},{thucLinh}");
                }

                // -- Dòng tổng cộng --
                decimal tongThucLinh = data.Sum(x => x.LuongThucNhan_BaoCao);
                sb.AppendLine($",,,,,,,,,TỔNG CỘNG: {tongThucLinh:0}");

                // 3. Trả về file (Quan trọng: Dùng Encoding.UTF8 và Preamble để Excel hiển thị tiếng Việt đúng)
                var fileName = $"BangLuong_Thang{t}_{n}.csv";
                var encoding = System.Text.Encoding.UTF8;
                var bytes = encoding.GetPreamble().Concat(encoding.GetBytes(sb.ToString())).ToArray();

                return File(bytes, "text/csv", fileName);
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi xuất file: " + ex.Message;
                return RedirectToAction("BaoCao", new { thang = thang, nam = nam });
            }
        }
        // POST: Thực hiện chốt thưởng
        [HttpPost]
        [CustomAuthorize(Roles = "Admin,KeToan")]
        public ActionResult XacNhanThuongTet(int nam)
        {
            var result = bangLuongDAO.ChotThuongTet(nam);
            if (result.Success)
                TempData["SuccessMessage"] = result.Message;
            else
                TempData["ErrorMessage"] = result.Message;

            return RedirectToAction("TongKetNam", new { nam = nam });
        }
        [CustomAuthorize(Roles = "Admin,KeToan")]
        public ActionResult TongKetNam(int? nam)
        {
            try
            {
                // Mặc định lấy năm hiện tại nếu không chọn
                int namChon = nam ?? DateTime.Now.Year;
                ViewBag.Nam = namChon;

                // Gọi DAO lấy danh sách thi đua (Hàm này đã có trong BangLuongDAO)
                var list = bangLuongDAO.GetTongKetNam(namChon);

                // Tính tổng tiền thưởng để hiển thị lên thẻ KPI ở View
                decimal tongThuong = 0;
                if (list != null && list.Count > 0)
                {
                    tongThuong = list.Sum(x => x.ThuongTet);
                }
                ViewBag.TongTienThuong = tongThuong;

                return View(list);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải dữ liệu tổng kết: " + ex.Message;
                return View(new System.Collections.Generic.List<QL_Luong_MVC.ViewModel.TongKetThiDuaVM>());
            }
        }
    }
}
