using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System.Web.Mvc;

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
        public ActionResult Create(LuongCoban luong)
        {
            if (ModelState.IsValid)
            {
                var result = luongDao.ExecuteAction("Thêm", luong);
                if (result.Success) return RedirectToAction("Index");
                ModelState.AddModelError("", result.Message);
            }
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luong);
        }

        public ActionResult Edit(int? id)
        {
            if (id == null) return HttpNotFound();
            var luong = luongDao.GetById(id.Value);
            if (luong == null) return HttpNotFound();

            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luong);
        }

        [HttpPost]
        public ActionResult Edit(LuongCoban luong)
        {
            if (ModelState.IsValid)
            {
                var result = luongDao.ExecuteAction("Sửa", luong);
                if (result.Success) return RedirectToAction("Index");
                ModelState.AddModelError("", result.Message);
            }
            ViewBag.DSChucVu = cvDao.GetAll();
            return View(luong);
        }

        public ActionResult Delete(int id)
        {
            var luong = luongDao.GetById(id);
            if (luong == null) return HttpNotFound();
            return View(luong);
        }

        [HttpPost, ActionName("DeleteConfirmed")]
        public ActionResult DeleteConfirmed(int id)
        {
            // Tạo object tạm chỉ cần ID và MaCV để xóa
            // Lưu ý: SP yêu cầu MaCV, nhưng logic xóa thường theo ID.
            // Ở đây ta cần lấy MaCV từ ID trước để truyền vào SP vì SP xóa theo MaCV
            var luong = luongDao.GetById(id);
            if (luong != null)
            {
                luongDao.ExecuteAction("Xóa", luong);
            }
            return RedirectToAction("Index");
        }
    }
}