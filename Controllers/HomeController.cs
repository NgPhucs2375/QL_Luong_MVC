using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            // ✅ Kiểm tra đăng nhập
            if (Session["TenDangNhap"] == null)
                return RedirectToAction("Login", "Login");

            // ✅ Kiểm tra quyền
            string username = Session["TenDangNhap"].ToString().ToLower();
            string role = Session["Quyen"]?.ToString();

            if (username != "admin" && role != "Admin")
            {
                TempData["Error"] = "Bạn không có quyền truy cập trang này!";
                return RedirectToAction("AccessDenied", "Login");
            }

            ViewBag.Username = username;
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}