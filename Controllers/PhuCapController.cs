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
        // GET: PhuCap
        DB db = new DB();

        public ActionResult Index()
        {
            return View(db.dsPhuCap);
        }

        public ActionResult Create()
        {
            ViewBag.DSNhanVien = db.dsNhanVien;
            return View();
        }

        [HttpPost]
        public ActionResult Create(PhuCap pc)
        {
            DB database = new DB();
            bool ok = database.ThemPhuCap(pc);
            if (ok)
                return RedirectToAction("Index");
            else
            {
                ViewBag.ThongBao = "Lỗi khi thêm phụ cấp.";
                ViewBag.DSNhanVien = db.dsNhanVien;
                return View(pc);
            }
        }

        // UC10 - xem tổng phụ cấp
        public ActionResult TongPhuCap(int id)
        {
            DB database = new DB();
            decimal tong = database.TongPhuCapNhanVien(id);
            ViewBag.Tong = tong;
            ViewBag.NhanVien = db.dsNhanVien.Find(nv => nv.IDNhanVien == id);
            return View();
        }
    
}
}