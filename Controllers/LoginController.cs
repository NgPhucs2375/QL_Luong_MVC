using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using QL_Luong_MVC.Models;
using System.Data.SqlClient;
using System.Data;

namespace QL_Luong_MVC.Controllers
{
    public class LoginController : Controller
    {
        DB db = new DB();

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

                // ✅ 1. Kiểm tra tài khoản admin mặc định
                if (username.ToLower() == "admin" && password == "123456")
                {
                    Session["TenDangNhap"] = "admin";
                    Session["Quyen"] = "Admin";
                    return RedirectToAction("Index", "Home");
                }

                // ✅ 2. Kiểm tra tài khoản trong CSDL
                using (SqlConnection con = new SqlConnection(db.conStr))
                {
                    con.Open();
                    string query = "SELECT * FROM TaiKhoan WHERE TenDangNhap=@user AND MatKhau=@pass";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@user", username);
                    cmd.Parameters.AddWithValue("@pass", password);

                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        Session["TenDangNhap"] = dr["TenDangNhap"].ToString();
                        Session["Quyen"] = dr["Quyen"].ToString();
                        Session["MaNV"] = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]);

                        dr.Close();
                        con.Close();

                        // ✅ Điều hướng dựa theo quyền
                        if (Session["Quyen"].ToString() == "Admin")
                            return RedirectToAction("Index", "Home");
                        else
                            return RedirectToAction("InfoNV", "NhanVien");
                    }

                    ViewBag.Error = "❌ Sai tên đăng nhập hoặc mật khẩu.";
                    dr.Close();
                    con.Close();
                }
            }
            catch (SqlException)
            {
                ViewBag.Error = "⚠️ Không thể kết nối đến cơ sở dữ liệu. Vui lòng thử lại sau.";
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Đã xảy ra lỗi: " + ex.Message;
            }

            return View();
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
                using (SqlConnection con = new SqlConnection(db.conStr))
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
