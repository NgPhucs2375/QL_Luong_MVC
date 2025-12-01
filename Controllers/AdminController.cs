using QL_Luong_MVC.DAO;
using System.Web.Mvc;
using QL_Luong_MVC.Models;

namespace QL_Luong_MVC.Controllers
{
    [CustomAuthorize(Roles = "Admin")]
    public class AdminController : Controller
    {

        DB db = new DB();
        //private readonly string strcon = "Data Source = LapCuaTwsn; database = QL_LuongNV; User ID = sa;Password = 134679";
        private readonly string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        //private readonly string strcon = "Data Source=admindA;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;";

        private TaiKhoanDAO tkDao = new TaiKhoanDAO();


        public ActionResult Index()
        {
            if (Session["Quyen"]?.ToString() != "Admin") return RedirectToAction("Login", "Login");
            // Có thể thêm dashboard admin ở đây nếu muốn
            return RedirectToAction("QuanLyTaiKhoan");
        }

        public ActionResult QuanLyTaiKhoan()
        {
            if (Session["Quyen"]?.ToString() != "Admin") return RedirectToAction("Login", "Login");

            var list = tkDao.GetAll();
            return View(list);
        }

        public ActionResult CapQuyen(string user,string role)
        {
            if (string.IsNullOrEmpty(role)) role = "Admin"; // Mặc định nếu null

            // 3. Gọi DAO với tham số role động (Thay vì chữ "Admin" cứng như trước)
            if (tkDao.UpdateRole(user, role))
                TempData["ThongBao"] = $"Đã cập nhật quyền {role} cho tài khoản {user}.";
            else
                TempData["ThongBao"] = "Lỗi hệ thống khi cập nhật quyền.";

            return RedirectToAction("QuanLyTaiKhoan");
        }

        public ActionResult XoaQuyen(string user)
        {
            if (tkDao.UpdateRole(user, "User")) // Hoặc "NhanVien"
                TempData["ThongBao"] = $"Đã xóa quyền Admin của {user}.";
            else
                TempData["ThongBao"] = "Lỗi khi xóa quyền.";

            return RedirectToAction("QuanLyTaiKhoan");
        }
    }
}