using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class HopDongController : Controller
    {
        private HopDongDAO hdDao = new HopDongDAO();
        private NhanVienDAO nvDao = new NhanVienDAO();

        public ActionResult Index()
        {
            return View(hdDao.GetAll());
        }

        public ActionResult Create()
        {
            ViewBag.DSNhanVien = nvDao.GetAll();
            return View();
        }

        [HttpPost]
        public ActionResult Create(HopDong hd)
        {
            var result = hdDao.Insert(hd);
            if (result.Success)
                return RedirectToAction("Index");

            ViewBag.ThongBao = result.Message;
            ViewBag.DSNhanVien = nvDao.GetAll();
            return View(hd);
        }
    }
}