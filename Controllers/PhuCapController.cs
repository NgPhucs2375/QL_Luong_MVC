using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class PhuCapController : Controller
    {
        DB db = new DB();

        // Danh sách phụ cấp
        public ActionResult Index()
        {
            return View(db.dsPhuCap);
        }

        // Form thêm phụ cấp
        public ActionResult Create()
        {
            ViewBag.DSNhanVien = db.dsNhanVien;
            return View();
        }

        [HttpPost]
        public ActionResult Create(PhuCap pc)
        {
            bool ok = db.ThemPhuCap(pc);
            if (ok)
                return RedirectToAction("Index");
            else
            {
                ViewBag.ThongBao = "Lỗi khi thêm phụ cấp.";
                ViewBag.DSNhanVien = db.dsNhanVien;
                return View(pc);
            }
        }

        // Plan (pseudocode):
        // - In TongPhuCap(int? id), after finding nhanVien, use nhanVien.IDNhanVien (non-null)
        // - Pass this concrete int to DB.TongPhuCapNhanVien to fix CS1503
        // - Also use this concrete int for filtering dsPhuCap to keep consistency
        // - Keep the rest of the logic unchanged

        // UC10 - Xem tổng phụ cấp nhân viên
        public ActionResult TongPhuCap(int? id)
        {
            // Tìm nhân viên
            var nhanVien = db.dsNhanVien.Find(nv => nv.IDNhanVien == id);
            if (nhanVien == null)
            {
                ViewBag.NhanVien = null;
                return View();
            }

            // Dùng IDNhanVien cụ thể (int) để tránh lỗi int? -> int
            int idNV = nhanVien.IDNhanVien;

            // Tính tổng phụ cấp
            decimal tong = db.TongPhuCapNhanVien(idNV);
            ViewBag.Tong = tong;

            // Lấy chi tiết phụ cấp
            var chiTiet = db.dsPhuCap.Where(pc => pc.IDNhanVien_PhuCap == idNV).ToList();
            ViewBag.ChiTiet = chiTiet;

            // Tên phòng ban (nếu có)
            var phongBan = db.dsPhongBan.Find(pb => pb.IDPhongBan == nhanVien.IDPB_NhanVien);
            ViewBag.PhongBanName = phongBan?.NamePhongBan ?? "—";

            // Gán lại cho View
            ViewBag.NhanVien = nhanVien;

            return View();
        }
    }
}
