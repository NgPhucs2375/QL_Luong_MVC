using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class NhanVienController : Controller
    {
        // GET: NhanVien
        DB db = new DB();

        public ActionResult InfoNV()
        {
            if (Session["MaNV"] == null)
                return RedirectToAction("Login", "Login");

            int maNV = Convert.ToInt32(Session["MaNV"]);
            var nv = db.dsNhanVien.FirstOrDefault(x => x.IDNhanVien == maNV);

            return View(nv);
        }
        string conStr = "Data Source=.;Initial Catalog=QL_LuongNV;Integrated Security=True";

        [HttpGet]
        public ActionResult Them()
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

            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = @"INSERT INTO NhanVien 
                            (HoTen, GioiTinh, NgaySinh, DiaChi, DienThoai, Email, TrangThai, MaCV, MaPB)
                           VALUES
                            (@HoTen, @GioiTinh, @NgaySinh, @DiaChi, @DienThoai, @Email, @TrangThai, @MaCV, @MaPB)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@HoTen", (object)nv.FullNameNhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@GioiTinh", (object)nv.Sex_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@NgaySinh", (object)nv.DayOfBirth_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@DiaChi", (object)nv.Address_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@DienThoai", (object)nv.SDT_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Email", (object)nv.Email_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TrangThai", (object)nv.State_NhanVien ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@MaCV", nv.IDCV_NhanVien != 0 ? (object)nv.IDCV_NhanVien : DBNull.Value);
                        cmd.Parameters.AddWithValue("@MaPB", nv.IDPB_NhanVien != 0 ? (object)nv.IDPB_NhanVien : DBNull.Value);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            ViewBag.ThongBao = "✅ Thêm nhân viên thành công!";
                            ModelState.Clear();
                            return View();
                        }
                        else
                        {
                            ViewBag.ThongBao = "⚠️ Không thể thêm nhân viên.";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.ThongBao = "❌ Lỗi hệ thống: " + ex.Message;
            }

            return View(nv);
        }
    }
}