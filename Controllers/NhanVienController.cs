using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class NhanVienController : Controller
    {
        // Khởi tạo các lớp truy cập dữ liệu (DAO)
        private NhanVienDAO nvDao = new NhanVienDAO();
        private PhongBanDAO pbDao = new PhongBanDAO();
        private ChucVuDAO cvDao = new ChucVuDAO();

        // --------------------- QUẢN LÝ NHÂN VIÊN ---------------------

        // 1. Xem thông tin cá nhân (Dành cho User)
        public ActionResult InfoNV()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("Login", "Login");

            int maNV = Convert.ToInt32(Session["MaNV"]);
            var nv = nvDao.GetById(maNV);

            if (nv == null) return HttpNotFound();
            return View(nv);
        }

        // 2. Danh sách nhân viên (Dành cho Admin)
        public ActionResult DanhSachNV()
        {
            var list = nvDao.GetAll();
            return View(list);
        }

        // 3. Thêm nhân viên
        [HttpGet]
        public ActionResult ThemNV()
        {
            // Nạp dữ liệu cho Dropdownlist ở View
            ViewBag.DSPhongBan = pbDao.GetAll();
            ViewBag.DSChucVu = cvDao.GetAll();
            return View();
        }

        [HttpPost]
        public ActionResult ThemNV(NhanVien nv)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ThongBao = "Vui lòng kiểm tra lại thông tin.";
                // Load lại dropdown nếu validate fail
                ViewBag.DSPhongBan = pbDao.GetAll();
                ViewBag.DSChucVu = cvDao.GetAll();
                return View(nv);
            }

            var result = nvDao.Insert(nv);
            ViewBag.ThongBao = result.Message;

            if (result.Success)
            {
                ModelState.Clear();
                // Load lại dropdown để thêm người tiếp theo
                ViewBag.DSPhongBan = pbDao.GetAll();
                ViewBag.DSChucVu = cvDao.GetAll();
                return View(); // Trả về form trống
            }
            else
            {
                // Nếu lỗi, giữ nguyên dữ liệu cũ để sửa
                ViewBag.DSPhongBan = pbDao.GetAll();
                ViewBag.DSChucVu = cvDao.GetAll();
                return View(nv);
            }
        }

        // 4. Sửa nhân viên
        [HttpGet]
        public ActionResult SuaNV(int id)
        {
            var nv = nvDao.GetById(id);
            if (nv == null)
            {
                TempData["ThongBao"] = "⚠️ Không tìm thấy nhân viên!";
                return RedirectToAction("DanhSachNV");
            }
            // Load Dropdown cho View Sửa
            ViewBag.DSPhongBan = pbDao.GetAll();
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(nv);
        }

        [HttpPost]
        public ActionResult SuaNV(NhanVien nv)
        {
            var result = nvDao.Update(nv);
            TempData["ThongBao"] = result.Message;

            if (result.Success)
                return RedirectToAction("DanhSachNV");

            // Nếu lỗi, load lại dropdown và hiển thị lại form
            ViewBag.DSPhongBan = pbDao.GetAll();
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(nv);
        }

        // 5. Xóa nhân viên
        public ActionResult XoaNV(int id)
        {
            // Hiển thị trang xác nhận xóa
            var nv = nvDao.GetById(id);
            if (nv == null) return HttpNotFound();
            return View(nv);
        }

        [HttpPost, ActionName("DeleteConfirmed")]
        public ActionResult XoaNVConfirm(int id)
        {
            var result = nvDao.Delete(id);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachNV");
        }


        // --------------------- QUẢN LÝ PHÒNG BAN ---------------------

        public ActionResult DanhSachPB()
        {
            var list = pbDao.GetAll();
            return View(list);
        }

        [HttpGet]
        public ActionResult ThemPB()
        {
            return View();
        }

        [HttpPost]
        public ActionResult ThemPB(PhongBan pb)
        {
            var result = pbDao.Insert(pb);
            ViewBag.ThongBao = result.Message;
            if (result.Success) ModelState.Clear();
            return View();
        }

        [HttpGet]
        public ActionResult SuaPB(int id)
        {
            var pb = pbDao.GetById(id);
            if (pb == null) return HttpNotFound();
            return View(pb);
        }

        [HttpPost]
        public ActionResult SuaPB(PhongBan pb)
        {
            var result = pbDao.Update(pb);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachPB");
        }

        [HttpPost]
        public ActionResult XoaPB(int id) // id = MaPB
        {
            var result = pbDao.Delete(id);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachPB");
        }

        // Xem nhân viên trong phòng ban
        public ActionResult ChiTietNV(int id)
        {
            var allNV = nvDao.GetAll();
            var nhanviens = allNV.Where(nv => nv.IDPB_NhanVien == id).ToList();

            var phong = pbDao.GetById(id);
            ViewBag.TenPhong = phong?.NamePhongBan ?? "Không xác định";

            return View(nhanviens);
        }
    }
}