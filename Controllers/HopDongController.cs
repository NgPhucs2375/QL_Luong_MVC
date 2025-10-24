using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class HopDongController : Controller
    {
        // GET: HopDong
        DB db = new DB();

        // Danh sách hợp đồng
        public ActionResult Index()
        {
            return View(db.dsHopDong);
        }

        // Form thêm hợp đồng
        public ActionResult Create()
        {
            ViewBag.DSNhanVien = db.dsNhanVien;
            return View();
        }

        // Xử lý thêm hợp đồng
        [HttpPost]
        public ActionResult Create(HopDong hd)
        {
            DB database = new DB();
            bool ok = database.ThemHopDong(hd);
            if (ok)
                return RedirectToAction("Index");
            else
            {
                ViewBag.ThongBao = "Lỗi khi thêm hợp đồng.";
                ViewBag.DSNhanVien = db.dsNhanVien;
                return View(hd);
            }
        }
    }
}