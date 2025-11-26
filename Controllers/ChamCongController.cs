using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using System;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    /// <summary>
    /// Controller quản lý chấm công nhân viên
    /// Chức năng: UC6 (Chấm công), UC7 (Ngăn trùng), UC8 (Tính giờ tăng ca)
    /// </summary>
    public class ChamCongController : Controller
    {
        // Khởi tạo DAO để truy cập database
        private readonly BangChamCongDAO chamCongDAO = new BangChamCongDAO();
        private readonly NhanVienDAO nhanVienDAO = new NhanVienDAO();

        // ==================================================================================
        // UC6: HIỂN THỊ DANH SÁCH CHẤM CÔNG
        // ==================================================================================

        /// <summary>
        /// [UC6] Trang chủ - Hiển thị danh sách chấm công
        /// Route: /ChamCong/Index
        /// </summary>
        public ActionResult Index(int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                // Lấy danh sách chấm công theo tháng/năm
                var danhSach = chamCongDAO.GetByThang(thangHienTai, namHienTai);

                // Truyền tháng/năm sang View để hiển thị
                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;

                return View(danhSach);
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải danh sách chấm công: " + ex.Message;
                return View();
            }
        }

        // ==================================================================================
        // UC6: THÊM CHẤM CÔNG MỚI
        // ==================================================================================

        /// <summary>
        /// [UC6] Hiển thị form thêm chấm công
        /// Route: GET /ChamCong/Create
        /// </summary>
        [HttpGet]
        public ActionResult Create()
        {
            try
            {
                // Lấy danh sách nhân viên để hiển thị trong dropdown
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");

                // Set ngày mặc định là hôm nay
                ViewBag.NgayMacDinh = DateTime.Now.ToString("yyyy-MM-dd");

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tải form: " + ex.Message;
                return View();
            }
        }

        /// <summary>
        /// [UC6 + UC7] Xử lý thêm chấm công
        /// Trigger trg_PreventDuplicate_ChanCong sẽ tự động kiểm tra trùng ngày
        /// Route: POST /ChamCong/Create
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(BangChamCong model)
        {
            try
            {
                // Kiểm tra validation từ Model
                if (!ModelState.IsValid)
                {
                    // Reload danh sách nhân viên nếu validation fail
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Kiểm tra nghiệp vụ: Ngày công phải từ 0-1
                if (model.DayCong_ChamCong < 0 || model.DayCong_ChamCong > 1)
                {
                    ModelState.AddModelError("DayCong_ChamCong", "Ngày công phải từ 0 đến 1");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Kiểm tra nghiệp vụ: Giờ tăng ca phải >= 0
                if (model.GioTangCa < 0)
                {
                    ModelState.AddModelError("GioTangCa", "Giờ tăng ca không được âm");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }

                // Gọi DAO để thêm chấm công
                // UC7: Trigger sẽ tự động kiểm tra trùng ngày
                var result = chamCongDAO.Insert(model);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index");
                }
                else
                {
                    // Hiển thị lỗi từ Trigger (UC7: chấm công trùng ngày)
                    ViewBag.ErrorMessage = result.Message;
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien");
                return View(model);
            }
        }

        // ==================================================================================
        // UC6: SỬA CHẤM CÔNG
        // ==================================================================================

        /// <summary>
        /// [UC6] Hiển thị form sửa chấm công
        /// Route: GET /ChamCong/Edit/{id}
        /// </summary>
        [HttpGet]
        public ActionResult Edit(int id)
        {
            try
            {
                // Lấy thông tin chấm công cần sửa
                var chamCong = chamCongDAO.GetById(id);

                if (chamCong == null)
                {
                    TempData["ErrorMessage"] = "Không tìm thấy bản ghi chấm công";
                    return RedirectToAction("Index");
                }

                // Lấy danh sách nhân viên (nhưng không cho phép đổi nhân viên)
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", chamCong.IDNhanVien_ChamCong);

                return View(chamCong);
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi tải form: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        /// <summary>
        /// [UC6] Xử lý cập nhật chấm công
        /// Route: POST /ChamCong/Edit/{id}
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(BangChamCong model)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                // Kiểm tra validation nghiệp vụ
                if (model.DayCong_ChamCong < 0 || model.DayCong_ChamCong > 1)
                {
                    ModelState.AddModelError("DayCong_ChamCong", "Ngày công phải từ 0 đến 1");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                if (model.GioTangCa < 0)
                {
                    ModelState.AddModelError("GioTangCa", "Giờ tăng ca không được âm");
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }

                // Gọi DAO để cập nhật
                var result = chamCongDAO.Update(model);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                    return RedirectToAction("Index");
                }
                else
                {
                    ViewBag.ErrorMessage = result.Message;
                    var danhSachNhanVien = nhanVienDAO.GetAll();
                    ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi hệ thống: " + ex.Message;
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", model.IDNhanVien_ChamCong);
                return View(model);
            }
        }

        // ==================================================================================
        // UC6: XÓA CHẤM CÔNG
        // ==================================================================================

        /// <summary>
        /// [UC6] Xóa bản ghi chấm công
        /// Route: POST /ChamCong/Delete/{id}
        /// </summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            try
            {
                var result = chamCongDAO.Delete(id);

                if (result.Success)
                {
                    TempData["SuccessMessage"] = result.Message;
                }
                else
                {
                    TempData["ErrorMessage"] = result.Message;
                }

                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi xóa: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        // ==================================================================================
        // UC8: XEM TỔNG GIỜ TĂNG CA THÁNG
        // ==================================================================================

        /// <summary>
        /// [UC8] Xem tổng giờ tăng ca của nhân viên theo tháng
        /// Route: /ChamCong/XemGioTangCa?maNV={maNV}&thang={thang}&nam={nam}
        /// </summary>
        public ActionResult XemGioTangCa(int? maNV, int? thang, int? nam)
        {
            try
            {
                // Nếu không truyền tháng/năm, lấy tháng/năm hiện tại
                int thangHienTai = thang ?? DateTime.Now.Month;
                int namHienTai = nam ?? DateTime.Now.Year;

                // Lấy danh sách nhân viên để chọn
                var danhSachNhanVien = nhanVienDAO.GetAll();
                ViewBag.DanhSachNhanVien = new SelectList(danhSachNhanVien, "IDNhanVien", "FullNameNhanVien", maNV);

                ViewBag.Thang = thangHienTai;
                ViewBag.Nam = namHienTai;

                // Nếu đã chọn nhân viên, tính tổng giờ tăng ca
                if (maNV.HasValue)
                {
                    // Gọi function fn_TongGioTangCa_Thang qua DAO
                    decimal tongGio = chamCongDAO.GetTongGioTangCaThang(maNV.Value, thangHienTai, namHienTai);

                    // Lấy thông tin nhân viên
                    var nhanVien = nhanVienDAO.GetById(maNV.Value);

                    ViewBag.TongGioTangCa = tongGio;
                    ViewBag.TienTangCa = tongGio * 50000; // 50,000 VNĐ/giờ
                    ViewBag.TenNhanVien = nhanVien?.FullNameNhanVien;
                }

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.ErrorMessage = "Lỗi khi tính giờ tăng ca: " + ex.Message;
                return View();
            }
        }
    }
}
