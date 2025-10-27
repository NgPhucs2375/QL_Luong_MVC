using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class NhanVienController : Controller
    {
        DB db = new DB();

        public ActionResult InfoNV()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("Login", "Login");

            int maNV = Convert.ToInt32(Session["MaNV"]);
            var nv = db.dsNhanVien.FirstOrDefault(x => x.IDNhanVien == maNV);

            return View(nv);
        }
        public ActionResult DanhSachNV()
        {
            db.Lap_ListNhanVien(); // load lại danh sách mới nhất
            return View(db.dsNhanVien);
        }

        [HttpGet]
        public ActionResult ThemNV()
        {
            return View();
        }

        [HttpPost]
        public ActionResult ThemNV(NhanVien nv)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ThongBao = "Vui lòng nhập đầy đủ thông tin.";
                return View(nv);
            }

            var result = db.ThemNhanVien(nv);
            ViewBag.ThongBao = result.Message;

            if (result.Success)
                ModelState.Clear();

            return View();
        }
        [HttpGet]
        public ActionResult SuaNV(int id)
        {
            DB db = new DB();
            NhanVien nv = db.LayNhanVienTheoID(id); // gọi method mới
            if (nv == null)
            {
                TempData["ThongBao"] = " Không tìm thấy nhân viên!";
                return RedirectToAction("DanhSachNV");
            }
            return View(nv); // gửi dữ liệu sang view
        }
        [HttpPost]
        public ActionResult SuaNV(NhanVien nv)
        {
            var result = db.SuaNhanVien(nv);
            ViewBag.ThongBao = result.Message;
            return RedirectToAction("DanhSachNV");
        }
        [HttpGet]
        public ActionResult XoaNV(int id)
        {
            var result = db.XoaNhanVien(id);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachNV");
        }


        //======================Phòng Ban==========================

        public ActionResult DanhSachPB()
        {
            return View(db.dsPhongBan);
        }

        [HttpGet]
        public ActionResult ThemPB()
        {
            return View();
        }

        [HttpPost]
        public ActionResult ThemPB(PhongBan pb)
        {
            var result = db.ThemPhongBan(pb);
            ViewBag.ThongBao = result.Message;
            if (result.Success) ModelState.Clear();
            return View();
        }

        [HttpGet]
        public ActionResult SuaPB(int id)
        {
            PhongBan pb = db.LayPhongBanTheoID(id);
            if (pb == null)
            {
                TempData["ThongBao"] = "⚠️ Không tìm thấy phòng ban!";
                return RedirectToAction("DanhSachPB");
            }
            return View(pb);
        }

        [HttpPost]
        public ActionResult SuaPB(PhongBan pb)
        {
            var result = db.SuaPhongBan(pb);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachPB");
        }

        public ActionResult XoaPB(int id)
        {
            var result = db.XoaPhongBan(id);
            TempData["ThongBao"] = result.Message;
            return RedirectToAction("DanhSachPB");
        }

        public ActionResult ChiTietNV(int id) // id = MaPB
        {
            var nhanviens = db.dsNhanVien.Where(nv => nv.IDPB_NhanVien == id).ToList();
            var phong = db.dsPhongBan.FirstOrDefault(pb => pb.IDPhongBan == id);
            ViewBag.TenPhong = phong?.NamePhongBan ?? "Không xác định";
            return View(nhanviens);
        }
    }
}