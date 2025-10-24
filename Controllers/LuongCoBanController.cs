using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class LuongCoBanController : Controller
    {
        DB db = new DB();

        // GET: Danh sách LuongCoBan
        public ActionResult Index()
        {
            return View(db.dsLuongCoban);
        }

        // GET: Thêm mới
        public ActionResult Create()
        {
            ViewBag.DSChucVu = db.dsChucVu; // để hiển thị combobox chức vụ
            return View();
        }

        // Post: thêm mới
        [HttpPost]
        public ActionResult Create(LuongCoban luong)
        {
            if (ModelState.IsValid)
            {
                string sql = "Insert into LuongCoban (MaCV, MucLuong) VALUES(@MaCV, @MucLuong)" ;
                     using (SqlConnection con = new SqlConnection("Data Source=MSI;Initial Catalog=QL_LuongNV;User ID=sa;Password=123456"))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@MaCV", luong.IDChucVu_LuongCB);
                    cmd.Parameters.AddWithValue("@MucLuong", luong.MucLuong);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(luong);
        }
        // GET: Sửa
        public ActionResult Edit(int id)
        {
            var luong = db.dsLuongCoban.FirstOrDefault(x => x.IDLuongCoBan == id);
            ViewBag.DSChucVu = db.dsChucVu;
            return View(luong);
        }

        // POST: Sửa
        [HttpPost]
        public ActionResult Edit(LuongCoban model)
        {
            if (ModelState.IsValid)
            {
                string sql = "UPDATE LuongCoBan SET MaCV=@MaCV, MucLuong=@MucLuong WHERE MaLCB=@MaLCB";
                using (SqlConnection con = new SqlConnection("Data Source=MSI;Initial Catalog=QL_LuongNV;User ID=sa;Password=123456"))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@MaLCB", model.IDLuongCoBan);
                    cmd.Parameters.AddWithValue("@MaCV", model.IDChucVu_LuongCB);
                    cmd.Parameters.AddWithValue("@MucLuong", model.MucLuong);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(model);
        }

        // GET: Xóa
        public ActionResult Delete(int id)
        {
            string sql = "DELETE FROM LuongCoban WHERE MaLCB = @MaLCB";
            using (SqlConnection con = new SqlConnection("Data Source=MSI;Initial Catalog=QL_LuongNV;User ID=sa;Password=123456"))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@MaLCB", id); // hoặc model.IDLuongCoBan

                cmd.ExecuteNonQuery();
            }
            return RedirectToAction("Index");
        }
    }
}