using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class PhuCapController : Controller
    {
        private PhuCapDAO pcDao = new PhuCapDAO();
        private NhanVienDAO nvDao = new NhanVienDAO();
        private PhongBanDAO pbDao = new PhongBanDAO();

        public ActionResult Index()
        {
            return View(pcDao.GetAll());
        }

        public ActionResult Create()
        {
            ViewBag.DSNhanVien = nvDao.GetAll();
            return View();
        }

        [HttpPost]
        public ActionResult Create(PhuCap pc)
        {
            var result = pcDao.Insert(pc);
            if (result.Success)
                return RedirectToAction("Index");

            ViewBag.ThongBao = result.Message;
            ViewBag.DSNhanVien = nvDao.GetAll();
            return View(pc);
        }

        public ActionResult TongPhuCap(int? id)
        {
            if (id == null) return RedirectToAction("Index");

            int idNV = id.Value;
            var nhanVien = nvDao.GetById(idNV);

            if (nhanVien == null)
            {
                ViewBag.NhanVien = null;
                return View();
            }

            ViewBag.NhanVien = nhanVien;
            ViewBag.Tong = pcDao.GetTotalByNhanVienId(idNV);
            ViewBag.ChiTiet = pcDao.GetByNhanVienId(idNV);

            var phongBan = pbDao.GetById(nhanVien.IDPB_NhanVien);
            ViewBag.PhongBanName = phongBan?.NamePhongBan ?? "—";

            return View();
        }
    }
}