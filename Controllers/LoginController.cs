using QL_Luong_MVC.DAO;
using System;
using System.Web.Mvc;
using QL_Luong_MVC.Models;

namespace QL_Luong_MVC.Controllers
{
    public class LoginController : Controller
    {

        DB db = new DB();
        
        //private readonly string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        private readonly string strcon = "Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;";
        // --------------------- LOGIN ---------------------

        private TaiKhoanDAO tkDao = new TaiKhoanDAO();


        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(string username, string password)
        {
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                ViewBag.Error = "⚠️ Vui lòng nhập đầy đủ thông tin.";
                return View();
            }

            var result = tkDao.CheckLogin(username, password); // Dùng DAO

            if (result.Success)
            {
                // Lưu Session
                Session["TenDangNhap"] = username;
                Session["Quyen"] = result.Role;
                Session["MaNV"] = result.MaNV ?? 0;

                // --- LOGIC PHÂN LUỒNG MỚI ---

                // Nhóm Quản trị -> Vào Dashboard tổng quan
                if (result.Role == "Admin" || result.Role == "NhanSu" || result.Role == "KeToan")
                {
                    return RedirectToAction("Index", "Home");
                }

                // Nhóm Nhân viên (User) -> Vào Trang hồ sơ cá nhân
                else
                {
                    return RedirectToAction("InfoNV", "NhanVien");
                }
            }
            else
            {
                ViewBag.Error = result.Message;
                return View();
            }
        }

        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Login");
        }

        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Register(string TenDangNhap, string MatKhau, int MaNV)
        {
            var result = tkDao.Register(TenDangNhap, MatKhau, MaNV); // Dùng DAO

            if (result.Success)
                ViewBag.Success = result.Message;
            else
                ViewBag.Error = result.Message;

            return View();
        }
    }
}