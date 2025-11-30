using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{

    public class ChamCongController : Controller
    {
        // Khởi tạo DAO để truy cập database
        private readonly BangChamCongDAO chamCongDAO = new BangChamCongDAO();
        private readonly NhanVienDAO nhanVienDAO = new NhanVienDAO();


        public ActionResult Index(int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                // Lấy danh sách chấm công theo tháng/năm
                var danhSach = chamCongDAO.GetByThang(thangHienTai, namHienTai);

                // Truyền tháng/năm sang View để hiển thị
                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;

                return View(danhSach);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải danh sách chấm công: " + ex.Message;
                return View();
            }
        }


        [HttpGet]
        public ActionResult Create()
        {
            try
            {
                // Lấy danh sách nhân viên để hiển thị trong dropdown
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");

                // Set ngày mặc định là hôm nay
                ViewBag.NgayMacDinh = DateTime.Now.ToString("yyyy-MM-dd");

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải form: " + ex.Message;
                return View();
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(BangChamCong model)
        {
            try
            {
                // Kiểm tra validation từ Model
                if (!ModelState.IsValid)
                {
                    // Reload danh sách nhân viên nếu validation fail
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Kiểm tra nghiệp vụ: Ngày công phải từ 0-1
                if (model.DayCong_ChamCong < 0 || model.DayCong_ChamCong > 1)
                {
                    ModelState.AddModelError("DayCong_ChamCong", "Ngày công phải từ 0 đến 1");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Kiểm tra nghiệp vụ: Giờ tăng ca phải >= 0
                if (model.GioTangCa < 0)
                {
                    ModelState.AddModelError("GioTangCa", "Giờ tăng ca không được âm");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Gọi DAO để thêm chấm công
                // UC7: Trigger sẽ tự động kiểm tra trùng ngày
                var result = chamCongDAO.Insert(model);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index");
                }
                else
                {
                    // Hiển thị lỗi từ Trigger (UC7: chấm công trùng ngày)
                    ViewBag.ErrorMessage = result.Message;
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                return View(model);
            }
        }


        [HttpGet]
        public ActionResult Edit(int id)
        {
            try
            {
                // Lấy thông tin chấm công cần sửa
                var chamCong = chamCongDAO.GetById(id);

                if (chamCong == null)
                {
                    TempData["ErrorMessage"] = "Không tìm thấy bản ghi chấm công";
                    return RedirectToAction("Index");
                }

                // Lấy danh sách nhân viên (nhưng không cho phép đổi nhân viên)
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", chamCong.IDNhanVien_ChamCong);

                return View(chamCong);
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi tải form: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(BangChamCong model)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                // Kiểm tra validation nghiệp vụ
                if (model.DayCong_ChamCong < 0 || model.DayCong_ChamCong > 1)
                {
                    ModelState.AddModelError("DayCong_ChamCong", "Ngày công phải từ 0 đến 1");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                if (model.GioTangCa < 0)
                {
                    ModelState.AddModelError("GioTangCa", "Giờ tăng ca không được âm");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                // Gọi DAO để cập nhật
                var result = chamCongDAO.Update(model);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index");
                }
                else
                {
                    ViewBag.ErrorMessage = result.Message;
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            try
            {
                var result = chamCongDAO.Delete(id);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                }
                else
                {
                    TempData["ErrorMessage"] = result.Message;
                }

                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi xóa: " + ex.Message;
                return RedirectToAction("Index");
            }
        }


        public ActionResult XemGioTangCa(int? maNV, int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;
                string userRole = Session["Quyen"]?.ToString();
                int currentUserID = Convert.ToInt32(Session["MaNV"]);
                if (userRole == "User")
                {
                    // Gán cứng mã NV là chính mình
                    maNV = currentUserID;

                    // Chỉ tạo list có 1 người (là chính mình) để Dropdown không hiện người khác
                    var me = nhanVienDAO.GetById(currentUserID);
                    var listMe = new List<NhanVien> { me };
                    ViewBag.DanhSachNhanVien = new SelectList(listMe, "IDNhanVien", "FullNameNhanVien", currentUserID);
                }
                else
                {
                    // Nếu là Admin/HR -> Được xem tất cả (Code cũ)
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", maNV);
                }

                // Lấy danh sách nhân viên để chọn

                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;

                // Nếu đã chọn nhân viên, tính tổng giờ tăng ca
                if (maNV.HasValue)
                {
                    // Gọi function fn_TongGioTangCa_Thang qua DAO
                    decimal tongGio = chamCongDAO.GetTongGioTangCaThang(maNV.Value, thangHienTai, namHienTai);

                    // Lấy thông tin nhân viên
                    var nhanVien = nhanVienDAO.GetById(maNV.Value);

                    ViewBag.TongGioTangCa = tongGio;
                    ViewBag.TienTangCa = tongGio * 50000; // 50,000 VNĐ/giờ
                    ViewBag.TenNhanVien = nhanVien?.FullNameNhanVien;
                }

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tính giờ tăng ca: " + ex.Message;
                return View();
            }
        }

        // [User] Chức năng tự chấm công hàng ngày
        [CustomAuthorize(Roles = "User,Admin,NhanSu,KeToan")] // Ai cũng cần chấm công
        public ActionResult DiemDanhHangNgay()
        {
            int maNV = Convert.ToInt32(Session["MaNV"]);

            // 1. Kiểm tra hôm nay đã chấm chưa (Gọi qua DAO hoặc check trực tiếp)
            // Lưu ý: Logic này nên đẩy xuống DAO, ở đây viết gọn để bạn hiểu
            var daCham = chamCongDAO.GetByNhanVien(maNV)
                                    .Any(x => x.Day_ChamCong.Date == DateTime.Now.Date);

            if (daCham)
            {
                TempData["Error"] = "Hôm nay bạn đã chấm công rồi!";
                return RedirectToAction("DashboardUser", "Home");
            }

            // 2. Tạo bản ghi chấm công
            BangChamCong cc = new BangChamCong();
            cc.IDNhanVien_ChamCong = maNV;
            cc.Day_ChamCong = DateTime.Now;
            cc.DayCong_ChamCong = 1; // Mặc định chấm công là tính 1 ngày
            cc.GioTangCa = 0;        // Tăng ca phải đăng ký riêng hoặc HR sửa

            // 3. Gọi DAO lưu
            var result = chamCongDAO.Insert(cc);

            if (result.Success)
                TempData["SuccessMessage"] = "✅ Chấm công thành công! Chúc bạn một ngày làm việc tốt lành.";
            else
                TempData["Error"] = result.Message;

            return RedirectToAction("DashboardUser", "Home");
        }
    }
}
