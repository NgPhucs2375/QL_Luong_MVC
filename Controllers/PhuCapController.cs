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
                //return View();
            }
            var listChiTiet = pcDao.GetByNhanVienId(idNV);

            ViewBag.NhanVien = nhanVien;
            ViewBag.Tong = pcDao.GetTotalByNhanVienId(idNV);
            ViewBag.ChiTiet = pcDao.GetByNhanVienId(idNV);

            var phongBan = pbDao.GetById(nhanVien.IDPB_NhanVien);
            ViewBag.PhongBanName = phongBan?.NamePhongBan ?? "—";

            return View(listChiTiet);
        }
        // --- BỔ SUNG VÀO PhuCapController.cs ---

        [HttpGet]
        public ActionResult Edit(int id)
        {
            var pc = pcDao.GetById(id);
            if (pc == null) return HttpNotFound();

            // Lấy tên nhân viên để hiển thị cho rõ
            var nv = nvDao.GetById(pc.IDNhanVien_PhuCap);
            ViewBag.TenNhanVien = nv?.FullNameNhanVien ?? "Không xác định";

            return View(pc);
        }

        [HttpPost]
        public ActionResult Edit(PhuCap pc)
        {
            if (ModelState.IsValid)
            {
                var result = pcDao.Update(pc);
                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index");
                }
                ViewBag.ThongBao = result.Message;
            }
            // Nếu lỗi, load lại tên nhân viên
            var nv = nvDao.GetById(pc.IDNhanVien_PhuCap);
            ViewBag.TenNhanVien = nv?.FullNameNhanVien;
            return View(pc);
        }

        public ActionResult Delete(int id)
        {
            var result = pcDao.Delete(id);
            if (result.Success)
                TempData["SuccessMessage"] = result.Message;
            else
                TempData["Error"] = result.Message;

            return RedirectToAction("Index");
        }
    }
}