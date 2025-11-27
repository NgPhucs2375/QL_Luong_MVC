
using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;


namespace QL_Luong_MVC.Controllers
{
    public class LoginController : Controller
    {
        DB db = new DB();
        
        //private readonly string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        private readonly string strcon = "Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;";
        // --------------------- LOGIN ---------------------
        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Login(string username, string password)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                {
                    ViewBag.Error = "⚠️ Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.";
                    return View();
                }
                var result = db.CheckLogin(username, password);

                if (!result.Success)
                {
                    // Nếu có message trả về (lỗi kết nối hay sai), hiển thị
                    ViewBag.Error = result.Message ?? "Sai tên đăng nhập hoặc mật khẩu.";
                    return View();
                }

                // Đăng nhập thành công -> lưu session
                Session["TenDangNhap"] = username;
                Session["Quyen"] = result.Role ?? "User";
                Session["MaNV"] = result.MaNV ?? 0;

                // Điều hướng dựa trên quyền
                if ((result.Role ?? "User").Equals("Admin", StringComparison.OrdinalIgnoreCase))
                    return RedirectToAction("Index", "Home"); // hoặc controller admin nếu có
                else
                    return RedirectToAction("InfoNV", "NhanVien");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Đã xảy ra lỗi: " + ex.Message;
                return View();
            }
        }

        // --------------------- LOGOUT ---------------------
        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Login");
        }

        // --------------------- REGISTER ---------------------
        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Register(string TenDangNhap, string MatKhau, int MaNV)
        {
            try
            {
                // Kiểm tra dữ liệu đầu vào
                if (string.IsNullOrWhiteSpace(TenDangNhap) || string.IsNullOrWhiteSpace(MatKhau))
                {
                    ViewBag.Error = "⚠️ Vui lòng nhập đầy đủ thông tin.";
                    return View();
                }

                // Gọi hàm xử lý đăng ký trong DB
                var result = db.RegisterNhanVien(TenDangNhap, MatKhau, MaNV);

                if (result.Success)
                {
                    ViewBag.Success = "🎉 Đăng ký thành công! Bạn có thể đăng nhập ngay.";
                }
                else
                {
                    ViewBag.Error = result.Message;
                }
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi: " + ex.Message;
            }

            return View();
        }

        // --------------------- XEM THÔNG TIN NHÂN VIÊN ---------------------
        public ActionResult InfoNV()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("InfoNV", "NhanVien");

            int maNV = Convert.ToInt32(Session["MaNV"]);
            var nv = db.dsNhanVien.FirstOrDefault(x => x.IDNhanVien == maNV);

            return View(nv);
        }

        // --------------------- CẤP QUYỀN ADMIN ---------------------
        [HttpPost]
        public ActionResult CapQuyenAdmin(string tenDangNhap)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))

                {
                    con.Open();
                    string query = "UPDATE TaiKhoan SET Quyen = 'Admin' WHERE TenDangNhap = @TenDangNhap";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@TenDangNhap", tenDangNhap);

                    int result = cmd.ExecuteNonQuery();

                    if (result > 0)
                        ViewBag.Success = $"✅ Đã cấp quyền Admin cho tài khoản: {tenDangNhap}";
                    else
                        ViewBag.Error = "Không tìm thấy tài khoản cần cấp quyền.";

                    con.Close();
                }
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi: " + ex.Message;
            }

            return RedirectToAction("DanhSachTaiKhoan", "TaiKhoan"); // tuỳ bạn có trang này hay không
        }
    }
}
