using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    // LƯU Ý: KHÔNG đặt [CustomAuthorize] ở cấp độ Class để tránh xung đột quyền User
    public class NhanVienController : Controller
    {
        // Khởi tạo các lớp truy cập dữ liệu (DAO)
        private NhanVienDAO nvDao = new NhanVienDAO();
        private PhongBanDAO pbDao = new PhongBanDAO();
        private ChucVuDAO cvDao = new ChucVuDAO();


        // 1. Xem thông tin cá nhân (Profile)
        [CustomAuthorize] // Ai đăng nhập rồi cũng vào được
        public ActionResult InfoNV()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("Login", "Login");

            int maNV = Convert.ToInt32(Session["MaNV"]);
            var nv = nvDao.GetById(maNV);

            if (nv == null) return HttpNotFound();

            var chucVu = cvDao.GetAll().FirstOrDefault(x => x.IDChucVu == nv.IDCV_NhanVien);
            var phongBan = pbDao.GetAll().FirstOrDefault(x => x.IDPhongBan == nv.IDPB_NhanVien);
            ViewBag.TenChucVu = chucVu?.NameChucVu ?? "Chưa cập nhật";
            ViewBag.TenPhongBan = phongBan?.NamePhongBan ?? "Chưa cập nhật";

            PhuCapDAO pcDao = new PhuCapDAO();
            var listPhuCap = pcDao.GetByNhanVienId(maNV);

            ViewBag.ListPhuCap = listPhuCap;
            ViewBag.TongPhuCap = listPhuCap.Sum(x => x.SoTien_PhuCap);
            return View(nv);
        }

        // 2. [GET] Nhân viên tự sửa hồ sơ (Chỉ sửa thông tin liên hệ)
        [CustomAuthorize]
        [HttpGet]
        public ActionResult EditProfile()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("Login", "Login");

            int id = Convert.ToInt32(Session["MaNV"]);
            var nv = nvDao.GetById(id);

            if (nv == null) return HttpNotFound();
            return View(nv);
        }

        // 3. [POST] Xử lý lưu hồ sơ cá nhân
        [HttpPost]
        [CustomAuthorize]
        [ValidateAntiForgeryToken]
        public ActionResult EditProfile(NhanVien nvInput)
        {
            try
            {
                // Lấy ID từ Session để đảm bảo an toàn (không tin tưởng ID từ Form gửi lên)
                int currentUserId = Convert.ToInt32(Session["MaNV"]);

                // Lấy dữ liệu gốc từ Database
                var originalNV = nvDao.GetById(currentUserId);

                if (originalNV != null)
                {
                    // Chỉ cập nhật các trường cho phép (Thông tin liên hệ)
                    originalNV.Address_NhanVien = nvInput.Address_NhanVien;
                    originalNV.SDT_NhanVien = nvInput.SDT_NhanVien;
                    originalNV.Email_NhanVien = nvInput.Email_NhanVien;
                    originalNV.DayOfBirth_NhanVien = nvInput.DayOfBirth_NhanVien;
                    originalNV.Sex_NhanVien = nvInput.Sex_NhanVien;

                    // Các trường sau GIỮ NGUYÊN (User không được phép sửa):
                    // - Chức vụ (IDCV)
                    // - Phòng ban (IDPB)
                    // - Lương
                    // - Trạng thái

                    var result = nvDao.Update(originalNV);

                    if (result.Success)
                    {
                        TempData["SuccessMessage"] = "✅ Cập nhật hồ sơ thành công!";
                        return RedirectToAction("InfoNV");
                    }
                    else
                    {
                        TempData["Error"] = result.Message;
                    }
                }
                else
                {
                    TempData["Error"] = "Không tìm thấy thông tin nhân viên.";
                }
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Lỗi hệ thống: " + ex.Message;
            }

            return View(nvInput);
        }

        // ==================================================================================
        // PHẦN 2: QUẢN TRỊ NHÂN SỰ (DÀNH CHO ADMIN & NHÂN SỰ)
        // ==================================================================================

        // 4. Danh sách toàn bộ nhân viên
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult DanhSachNV()
        {
            var list = nvDao.GetAll();
            return View(list);
        }

        // 5. [GET] Thêm nhân viên mới
        [HttpGet]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult ThemNV()
        {
            // Nạp dữ liệu cho Dropdownlist
            LoadDropdownData();
            return View();
        }

        // 6. [POST] Xử lý thêm nhân viên
        [HttpPost]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        [ValidateAntiForgeryToken]
        public ActionResult ThemNV(NhanVien nv)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ThongBao = "Vui lòng kiểm tra lại thông tin nhập vào.";
                LoadDropdownData();
                return View(nv);
            }

            var result = nvDao.Insert(nv);

            if (result.Success)
            {
                TempData["SuccessMessage"] = result.Message;
                // Reset form để thêm người tiếp theo
                ModelState.Clear();
                LoadDropdownData();
                return View();
            }
            else
            {
                ViewBag.ThongBao = result.Message; // Hiển thị lỗi (ví dụ trùng Email)
                LoadDropdownData();
                return View(nv);
            }
        }

        // 7. [GET] Sửa nhân viên (Quyền Admin/HR sửa full thông tin)
        [HttpGet]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult SuaNV(int id)
        {
            var nv = nvDao.GetById(id);
            if (nv == null)
            {
                TempData["Error"] = "⚠️ Không tìm thấy nhân viên!";
                return RedirectToAction("DanhSachNV");
            }
            LoadDropdownData();
            return View(nv);
        }

        // 8. [POST] Xử lý sửa nhân viên
        [HttpPost]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        [ValidateAntiForgeryToken]
        public ActionResult SuaNV(NhanVien nv)
        {
            var result = nvDao.Update(nv);

            if (result.Success)
            {
                TempData["SuccessMessage"] = result.Message;
                return RedirectToAction("DanhSachNV");
            }

            ViewBag.ThongBao = result.Message;
            LoadDropdownData();
            return View(nv);
        }

        // 9. [GET] Xác nhận xóa nhân viên
        [CustomAuthorize(Roles = "Admin")] // Chỉ Admin cao nhất mới được xóa
        public ActionResult XoaNV(int id)
        {
            var nv = nvDao.GetById(id);
            if (nv == null) return HttpNotFound();
            return View(nv);
        }

        // 10. [POST] Thực hiện xóa
        [HttpPost, ActionName("DeleteConfirmed")]
        [CustomAuthorize(Roles = "Admin")]
        [ValidateAntiForgeryToken]
        public ActionResult XoaNVConfirm(int id) // Tham số id nhận từ Route hoặc Form
        {
            // id ở đây map với IDNhanVien
            var result = nvDao.Delete(id);

            if (result.Success)
                TempData["SuccessMessage"] = result.Message;
            else
                TempData["Error"] = result.Message;

            return RedirectToAction("DanhSachNV");
        }

        // ==================================================================================
        // PHẦN 3: QUẢN LÝ PHÒNG BAN
        // ==================================================================================

        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult DanhSachPB()
        {
            var list = pbDao.GetAll();
            return View(list);
        }

        [HttpGet]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult ThemPB()
        {
            return View();
        }

        [HttpPost]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult ThemPB(PhongBan pb)
        {
            var result = pbDao.Insert(pb);
            if (result.Success)
            {
                TempData["SuccessMessage"] = result.Message;
                return RedirectToAction("DanhSachPB");
            }

            ViewBag.ThongBao = result.Message;
            return View(pb);
        }

        [HttpGet]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult SuaPB(int id)
        {
            var pb = pbDao.GetById(id);
            if (pb == null) return HttpNotFound();
            return View(pb);
        }

        [HttpPost]
        [CustomAuthorize(Roles = "Admin,NhanSu")]
        public ActionResult SuaPB(PhongBan pb)
        {
            var result = pbDao.Update(pb);
            if (result.Success)
            {
                TempData["SuccessMessage"] = result.Message;
                return RedirectToAction("DanhSachPB");
            }

            ViewBag.ThongBao = result.Message;
            return View(pb);
        }

        [HttpPost]
        [CustomAuthorize(Roles = "Admin")]
        public ActionResult XoaPB(int IDPhongBan)
        {
            var result = pbDao.Delete(IDPhongBan);
            if (result.Success)
                TempData["SuccessMessage"] = result.Message;
            else
                TempData["Error"] = result.Message;

            return RedirectToAction("DanhSachPB");
        }

        // Xem danh sách nhân viên thuộc 1 phòng ban cụ thể
        [CustomAuthorize(Roles = "Admin,NhanSu,KeToan")]
        public ActionResult ChiTietNV(int id)
        {
            var allNV = nvDao.GetAll();
            var nhanviens = allNV.Where(nv => nv.IDPB_NhanVien == id).ToList();

            var phong = pbDao.GetById(id);
            ViewBag.TenPhong = phong?.NamePhongBan ?? "Không xác định";

            return View(nhanviens);
        }

        [CustomAuthorize(Roles = "Admin,NhanSu,KeToan")] // Chỉ quản lý được xem
        public ActionResult BaoCaoThamNien()
        {
            var list = nvDao.GetBaoCaoThamNien();

            // Thống kê sơ bộ cho View
            ViewBag.TongNhanSu = list.Count;
            ViewBag.SoNguoiTren5Nam = list.Count(x => x.SoThangLamViec >= 60);

            return View(list);
        }

        // ==================================================================================
        // HELPER METHODS
        // ==================================================================================
        private void LoadDropdownData()
        {
            ViewBag.DSPhongBan = pbDao.GetAll();
            ViewBag.DSChucVu = cvDao.GetAll();
        }
    }
}