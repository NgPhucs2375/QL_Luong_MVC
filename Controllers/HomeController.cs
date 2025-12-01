using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using QL_Luong_MVC.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace QL_Luong_MVC.Controllers
{
    public class HomeController : Controller
    {
        // Khởi tạo các DAO cần thiết
        private PhuCapDAO phuCapDAO = new PhuCapDAO();
        private BangLuongDAO bangLuongDAO = new BangLuongDAO();
        private NhanVienDAO nhanVienDAO = new NhanVienDAO();
        private HopDongDAO hopDongDAO = new HopDongDAO();
        private PhongBanDAO phongBanDAO = new PhongBanDAO();

        public ActionResult Index()
        {
            if (Session["TenDangNhap"] == null)
                return RedirectToAction("Login", "Login");

            string username = Session["TenDangNhap"].ToString().ToLower();
            string role = Session["Quyen"]?.ToString();

            if (role != "Admin" && role != "NhanSu" && role != "KeToan")
            {
                if (role == "User") return RedirectToAction("DashboardUser");
                return RedirectToAction("AccessDenied", "Login");
            }

            ViewBag.Username = username;

            // --- 1. LẤY DỮ LIỆU TỪ DAO (Thay vì dùng class DB) ---
            var listNhanVien = nhanVienDAO.GetAll();
            var listHopDong = hopDongDAO.GetAll();
            var listBangLuong = bangLuongDAO.GetAll(); // Lấy toàn bộ lịch sử lương
            var listPhuCap = phuCapDAO.GetAll();
            var listPhongBan = phongBanDAO.GetAll();

            // --- 2. TÍNH TOÁN KPI ---
            int totalNV = listNhanVien.Count(x => x.State_NhanVien == "Đang làm");

            // Đếm hợp đồng còn hiệu lực (Ngày kết thúc null hoặc lớn hơn hiện tại)
            int totalHD = listHopDong.Count(x => x.DayToEnd == null || x.DayToEnd > DateTime.Now);

            // Tổng lương CB hiện tại (Dựa trên nhân viên đang làm)
            decimal totalSalary = listNhanVien
                                    .Where(x => x.State_NhanVien == "Đang làm")
                                    .Sum(x => x.LuongHienTai);

            // Tổng phụ cấp (Dùng hàm SQL chuẩn xác)
            decimal totalAllowances = phuCapDAO.GetTongTienPhuCap_TuFunction(null);

            // --- 3. XỬ LÝ BIỂU ĐỒ LƯƠNG (Area Chart) ---
            var labels = new List<string>();
            var values = new List<decimal>();

            // Lấy mốc thời gian hiện tại
            var targetDate = DateTime.Now;

            // Chạy vòng lặp 12 tháng ngược về quá khứ
            for (int i = 11; i >= 0; i--)
            {
                var date = targetDate.AddMonths(-i);
                string label = date.ToString("MM/yyyy");
                labels.Add(label);

                // Lọc trong listBangLuong xem tháng đó tổng thực nhận là bao nhiêu
                decimal sumMonth = listBangLuong
                    .Where(bl => bl.Month == date.Month && bl.Nam == date.Year)
                    .Sum(bl => (decimal?)bl.LuongThucNhan_BangLuong) ?? 0;

                values.Add(sumMonth);
            }

            // --- 4. XỬ LÝ BIỂU ĐỒ PHỤ CẤP (Pie Chart) ---
            var allowanceLabels = new List<string>();
            var allowanceValues = new List<decimal>();

            if (listPhuCap != null && listPhuCap.Count > 0)
            {
                var allowanceGroups = listPhuCap
                    .GroupBy(p => p.Loai_PhuCap ?? "Khác")
                    .Select(g => new { Loai = g.Key, Tong = g.Sum(x => x.SoTien_PhuCap) })
                    .OrderByDescending(x => x.Tong)
                    .ToList();

                foreach (var item in allowanceGroups)
                {
                    allowanceLabels.Add(item.Loai);
                    allowanceValues.Add(item.Tong);
                }
            }

            // --- 5. SƠ ĐỒ NHÂN SỰ THEO PHÒNG BAN ---
            var departments = listPhongBan
                .OrderBy(pb => pb.NamePhongBan)
                .Select(pb => new DepartmentMembersVM
                {
                    DepartmentId = pb.IDPhongBan,
                    DepartmentName = pb.NamePhongBan,
                    // Lọc nhân viên thuộc phòng ban này
                    Employees = listNhanVien
                        .Where(nv => nv.IDPB_NhanVien == pb.IDPhongBan && nv.State_NhanVien == "Đang làm")
                        .OrderBy(nv => nv.FullNameNhanVien)
                        .Select(nv => new EmployeeVM
                        {
                            Id = nv.IDNhanVien,
                            Name = nv.FullNameNhanVien
                        }).ToList()
                }).ToList();

            // Đóng gói ViewModel
            var vm = new DashBoardViewModel
            {
                TotalEmployees = totalNV,
                TotalContracts = totalHD,
                TotalSalary = totalSalary,
                TotalAllowances = totalAllowances,
                SalaryByMonthLabels = labels,
                SalaryByMonthValues = values,
                AllowanceLabels = allowanceLabels,
                AllowanceValues = allowanceValues,
                Departments = departments,
            };

            return View(vm);
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";
            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";
            return View();
        }

        // Action DashboardUser và CheckIn giữ nguyên như cũ (Copy lại từ code của bạn nếu cần)
        public ActionResult DashboardUser()
        {
            if (Session["MaNV"] == null) return RedirectToAction("Login", "Login");
            int idNhanVien = Convert.ToInt32(Session["MaNV"]);

            // Thời gian hiện tại
            int thang = DateTime.Now.Month;
            int nam = DateTime.Now.Year;

            // 1. LẤY DỮ LIỆU CHẤM CÔNG (Real-time)
            // Dùng DAO để lấy dữ liệu chấm công tháng này
            var listCongThang = new BangChamCongDAO().GetByThang(thang, nam)
                                                     .Where(x => x.IDNhanVien_ChamCong == idNhanVien).ToList();

            ViewBag.SoNgayCong = listCongThang.Sum(x => x.DayCong_ChamCong);

            // Tính tổng giờ tăng ca thực tế từ bảng chấm công (thay vì bảng lương chưa tính)
            decimal tongGioTangCa = listCongThang.Sum(x => x.GioTangCa);
            ViewBag.GioTangCa = tongGioTangCa;

            // Kiểm tra hôm nay đã check-in chưa
            ViewBag.IsCheckedIn = listCongThang.Any(x => x.Day_ChamCong.Date == DateTime.Now.Date);

            // Lấy 10 hoạt động gần nhất (cho bảng bên phải)
            ViewBag.RecentActivities = new BangChamCongDAO()
                .GetByNhanVien(idNhanVien)
                .OrderByDescending(x => x.Day_ChamCong)
                .Take(10)
                .ToList();

            // 2. LẤY THÔNG TIN CÁ NHÂN & HỢP ĐỒNG (Dùng DAO, bỏ class DB cũ)
            var nhanVien = nhanVienDAO.GetById(idNhanVien);
            var hopDong = hopDongDAO.GetListByNhanVien(idNhanVien).FirstOrDefault();

            // Lấy lương tháng gần nhất đã chốt (để hiển thị tham khảo)
            var luongGanNhat = bangLuongDAO.GetByNhanVien(idNhanVien).FirstOrDefault();

            ViewBag.NhanVien = nhanVien;
            ViewBag.HopDong = hopDong;
            ViewBag.LuongGanNhat = luongGanNhat;

            // 3. DỮ LIỆU BIỂU ĐỒ CỘT (Lịch sử lương 6 tháng)
            var listLuongHistory = bangLuongDAO.GetByNhanVien(idNhanVien)
                    .OrderByDescending(x => x.Nam).ThenByDescending(x => x.Month)
                    .Take(6)
                    .OrderBy(x => x.Month)
                    .ToList();

            ViewBag.SalaryHistoryLabels = listLuongHistory.Select(x => "T" + x.Month).ToList();
            ViewBag.SalaryHistoryValues = listLuongHistory.Select(x => x.LuongThucNhan_BangLuong).ToList();

            // 4. DỮ LIỆU BIỂU ĐỒ TRÒN (Cơ cấu thu nhập ƯỚC TÍNH tháng này)
            // A. Lương cứng (Lấy từ NV hoặc HĐ)
            decimal luongHienTai = nhanVien != null ? nhanVien.LuongHienTai : 0;

            // B. Phụ cấp (Lấy tổng các khoản phụ cấp hiện có)
            decimal tongPhuCap = phuCapDAO.GetTotalByNhanVienId(idNhanVien);

            // C. Tăng ca ước tính (Giờ tăng ca thực tế * 50.000)
            decimal tienTangCaUocTinh = tongGioTangCa * 50000;

            // Truyền sang View để vẽ biểu đồ
            ViewBag.PieLuongCB = luongHienTai;
            ViewBag.PiePhuCap = tongPhuCap;
            ViewBag.PieTangCa = tienTangCaUocTinh;
            ViewBag.TongPhuCap = tongPhuCap; // Hiển thị số ở thẻ KPI

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CheckIn()
        {
            if (Session["MaNV"] == null) return RedirectToAction("Login", "Login");
            int maNV = Convert.ToInt32(Session["MaNV"]);
            BangChamCongDAO dao = new BangChamCongDAO();

            var listCong = dao.GetByNhanVien(maNV);
            if (listCong.Any(x => x.Day_ChamCong.Date == DateTime.Now.Date))
            {
                TempData["Message"] = "Hôm nay bạn đã chấm công rồi!";
                TempData["Type"] = "warning";
                return RedirectToAction("DashboardUser");
            }

            var result = dao.Insert(new BangChamCong { IDNhanVien_ChamCong = maNV, Day_ChamCong = DateTime.Now, DayCong_ChamCong = 1, GioTangCa = 0 });

            TempData["Message"] = result.Success ? "Chấm công thành công!" : "Lỗi: " + result.Message;
            TempData["Type"] = result.Success ? "success" : "danger";

            return RedirectToAction("DashboardUser");
        }
    }
}