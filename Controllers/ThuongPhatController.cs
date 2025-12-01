using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    [CustomAuthorize(Roles = "Admin,KeToan")]
    public class ThuongPhatController : Controller
    {
        private ThuongPhatDAO tpDao = new ThuongPhatDAO();
        private NhanVienDAO nvDao = new NhanVienDAO();

        public ActionResult Index(int? thang, int? nam)
        {
            int t = thang ?? DateTime.Now.Month;
            int n = nam ?? DateTime.Now.Year;
            ViewBag.Thang = t;
            ViewBag.Nam = n;

            var list = tpDao.GetByMonth(t, n);
            return View(list);
        }

        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.DSNhanVien = nvDao.GetAll().Select(x => new SelectListItem
            {
                Value = x.IDNhanVien.ToString(),
                Text = $"{x.FullNameNhanVien} - {x.IDNhanVien}"
            }).ToList();

            return View(new ThuongPhat { Thangg = DateTime.Now.Month, Namm = DateTime.Now.Year });
        }

        [HttpPost]
        public ActionResult Create(ThuongPhat model)
        {
            if (model.SoTien_ThuongPhat <= 0)
                ModelState.AddModelError("SoTien_ThuongPhat", "Số tiền phải lớn hơn 0");

            if (ModelState.IsValid)
            {
                var result = tpDao.Insert(model);
                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index", new { thang = model.Thangg, nam = model.Namm });
                }
                ViewBag.ErrorMessage = result.Message;
            }

            ViewBag.DSNhanVien = nvDao.GetAll().Select(x => new SelectListItem
            {
                Value = x.IDNhanVien.ToString(),
                Text = $"{x.FullNameNhanVien} - {x.IDNhanVien}"
            }).ToList();
            return View(model);
        }

        [HttpPost]
        public ActionResult Delete(int id)
        {
            tpDao.Delete(id);
            TempData["SuccessMessage"] = "Đã xóa bản ghi.";
            return RedirectToAction("Index");
        }
    }
}