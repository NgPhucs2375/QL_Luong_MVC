using QL_Luong_MVC.DAO;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class AdminController : Controller
    {
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

        public ActionResult CapQuyen(string user)
        {
            if (tkDao.UpdateRole(user, "Admin"))
                TempData["ThongBao"] = $"Đã cấp quyền Admin cho {user}.";
            else
                TempData["ThongBao"] = "Lỗi khi cấp quyền.";

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