using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
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

        [CustomAuthorize] // Ai đăng nhập cũng được xem của mình
        public ActionResult XemHopDongCaNhan()
        {
            if (Session["MaNV"] == null) return RedirectToAction("Login", "Login");
            int maNV = Convert.ToInt32(Session["MaNV"]);

            // 1. Lấy thông tin nhân viên để hiển thị tên
            NhanVienDAO nvDao = new NhanVienDAO();
            var nv = nvDao.GetById(maNV);
            ViewBag.TenNhanVien = nv?.FullNameNhanVien ?? "Bạn";

            // 2. Lấy danh sách hợp đồng
            var listHD = hdDao.GetListByNhanVien(maNV);

            return View(listHD);
        }
    }
}