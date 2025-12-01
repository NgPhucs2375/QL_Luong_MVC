using QL_Luong_MVC.DAO;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    [CustomAuthorize(Roles = "Admin")]
    public class CongCuController : Controller
    {
        private CongCuDAO dao = new CongCuDAO();

        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult TangLuong(decimal phanTram)
        {
            if (dao.TangLuongHangLoat(phanTram))
                TempData["Success"] = $"Đã tăng {phanTram}% lương cho toàn bộ nhân viên!";
            else
                TempData["Error"] = "Có lỗi xảy ra khi tăng lương.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        public ActionResult BackupDB()
        {
            if (dao.BackupDatabase())
                TempData["Success"] = "Backup Database thành công vào ổ D:/Backup_QLLuong";
            else
                TempData["Error"] = "Lỗi backup (Check quyền ghi ổ đĩa server).";
            return RedirectToAction("Index");
        }
    }
}