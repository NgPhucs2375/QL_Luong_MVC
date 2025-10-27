using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class AdminController : Controller
    {
        // GET: Admin
        DB db = new DB();

        // Chỉ admin mới vào được
        public ActionResult QuanLyTaiKhoan()
        {
            if (Session["Quyen"] == null || Session["Quyen"].ToString() != "Admin")
                return RedirectToAction("Login", "Login");

            db.Lap_ListTaiKhoan();
            return View(db.dsTaiKhoan);
        }

        //  Cấp quyền Admin cho tài khoản
        public ActionResult CapQuyen(string user)
        {
            if (Session["Quyen"] == null || Session["Quyen"].ToString() != "Admin")
                return RedirectToAction("Login", "Login");

            try
            {
                using (SqlConnection conn = new SqlConnection(db.conStr))
                {
                    conn.Open();
                    string sql = "UPDATE TaiKhoan SET Quyen = N'Admin' WHERE TenDangNhap = @user";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@user", user);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            TempData["ThongBao"] = $" Đã cấp quyền Admin cho {user}.";
                        else
                            TempData["ThongBao"] = $" Không tìm thấy tài khoản {user}.";
                    }
                }
            }
            catch (Exception ex)
            {
                TempData["ThongBao"] = " Lỗi khi cấp quyền: " + ex.Message;
            }

            return RedirectToAction("QuanLyTaiKhoan");
        }
        public ActionResult XoaQuyen(string user)
        {
            if (Session["Quyen"] == null || Session["Quyen"].ToString() != "Admin")
                return RedirectToAction("Login", "Login");

            try
            {
                using (SqlConnection conn = new SqlConnection(db.conStr))
                {
                    conn.Open();
                    string sql = "UPDATE TaiKhoan SET Quyen = N'User' WHERE TenDangNhap = @user";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@user", user);
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                            TempData["ThongBao"] = $" Đã xóa quyền Admin của {user}.";
                        else
                            TempData["ThongBao"] = $" Không tìm thấy tài khoản {user}.";
                    }
                }
            }
            catch (Exception ex)
            {
                TempData["ThongBao"] = "❗ Lỗi khi xóa quyền: " + ex.Message;
            }

            return RedirectToAction("QuanLyTaiKhoan");
        }
    }
}