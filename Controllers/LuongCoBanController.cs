using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System.Web.Mvc;
using System.Data;
using System.Data.SqlClient;


namespace QL_Luong_MVC.Controllers
{
    public class LuongCoBanController : Controller
    {
        private LuongCoBanDAO luongDao = new LuongCoBanDAO();
        private ChucVuDAO cvDao = new ChucVuDAO();

        public ActionResult Index()
        {
            return View(luongDao.GetAll());
        }

        public ActionResult Create()
        {
            ViewBag.DSChucVu = cvDao.GetAll();
            return View();
        }

        [HttpPost]
        public ActionResult Create(LuongCoban luongCoBan)
        {
            if (ModelState.IsValid)
            {

                string sql = "Insert into LuongCoban (MaCV, MucLuong) VALUES(@MaCV, @MucLuong)" ;
                using (SqlConnection con = new SqlConnection("Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;"))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@MaCV", luongCoBan.IDChucVu_LuongCB);
                    cmd.Parameters.AddWithValue("@MucLuong", luongCoBan.MucLuong);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luongCoBan);
        }

        public ActionResult Edit(int? id)
        {
            if (id == null) return HttpNotFound();
            var luongCoBan = luongDao.GetById(id.Value);
            if (luongCoBan == null) return HttpNotFound();

            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luongCoBan);
        }

        [HttpPost]
        public ActionResult Edit(LuongCoban luongCoBan)
        {
            if (ModelState.IsValid)
            {

                string sql = "UPDATE LuongCoBan SET MaCV=@MaCV, MucLuong=@MucLuong WHERE MaLCB=@MaLCB";
                using (SqlConnection con = new SqlConnection("Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;"))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@MaLCB", luongCoBan.IDLuongCoBan);
                    cmd.Parameters.AddWithValue("@MaCV", luongCoBan.IDChucVu_LuongCB);
                    cmd.Parameters.AddWithValue("@MucLuong", luongCoBan.MucLuong);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luongCoBan);
        }

        // GET: Xóa
        public ActionResult Delete(int id)
        {
            string sql = "DELETE FROM LuongCoban WHERE MaLCB = @MaLCB";
            using (SqlConnection con = new SqlConnection("Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;"))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@MaLCB", id);
                cmd.ExecuteNonQuery();
            }
            return RedirectToAction("Index");
        }

        //public ActionResult Delete(int id)
        //{
        //    var luongCoBan = luongDao.GetById(id);
        //    if (luongCoBan == null) return HttpNotFound();
        //    return View(luongCoBan);
        //}

        [HttpPost, ActionName("DeleteConfirmed")]
        public ActionResult DeleteConfirmed(int id)
        {
            var luongCoBan = luongDao.GetById(id);
            if (luongCoBan != null)
            {
                luongDao.ExecuteAction("Xóa", luongCoBan);
            }
            return RedirectToAction("Index");
        }
    }
}