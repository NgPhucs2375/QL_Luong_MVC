using QL_Luong_MVC.DAO;
using System;
using System.Web.Mvc;
using QL_Luong_MVC.Models;

namespace QL_Luong_MVC.Controllers
{
    public class LoginController : Controller
    {

        DB db = new DB();

        private readonly string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        //private readonly string strcon = "Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;";
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
                    // Chuyển hướng về Dashboard dành riêng cho User
                    return RedirectToAction("DashboardUser", "Home");
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

        [HttpGet]
        public ActionResult ChangePassword()
        {
            // Kiểm tra đăng nhập
            if (Session["TenDangNhap"] == null)
            {
                return RedirectToAction("Login", "Login");
            }
            return View();
        }

        [HttpPost]
        public ActionResult ChangePassword(string oldPassword, string newPassword, string confirmNewPassword)
        {
            if (Session["TenDangNhap"] == null)
            {
                return RedirectToAction("Login", "Login");
            }

            // 1. Kiểm tra đầu vào
            if (string.IsNullOrWhiteSpace(oldPassword) || string.IsNullOrWhiteSpace(newPassword) || string.IsNullOrWhiteSpace(confirmNewPassword))
            {
                ViewBag.Error = "Vui lòng nhập đầy đủ mật khẩu.";
                return View();
            }

            if (newPassword != confirmNewPassword)
            {
                ViewBag.Error = "Mật khẩu mới và Xác nhận mật khẩu không khớp.";
                return View();
            }

            // Lấy Tên đăng nhập từ Session
            string username = Session["TenDangNhap"].ToString();

            // 2. Thực hiện đổi mật khẩu qua DAO
            var result = tkDao.ChangePassword(username, oldPassword, newPassword);

            if (result.Success)
            {
                // Xóa Session và buộc đăng nhập lại
                Session.Clear();
                TempData["SuccessMessage"] = "🎉 Đổi mật khẩu thành công! Vui lòng đăng nhập lại.";
                return RedirectToAction("Login", "Login");
            }
            else
            {
                ViewBag.Error = result.Message;
                return View();
            }
        }
    }
}