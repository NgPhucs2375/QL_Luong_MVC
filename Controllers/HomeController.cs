using QL_Luong_MVC.DAO;
using QL_Luong_MVC.Models;
using QL_Luong_MVC.ViewModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;


namespace QL_Luong_MVC.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            // 1. Kiểm tra đăng nhập
            if (Session["TenDangNhap"] == null)
                return RedirectToAction("Login", "Login");

            string role = Session["Quyen"]?.ToString();

            // 2. LOGIC ĐIỀU HƯỚNG MỚI (FIX LỖI)
            // Nếu KHÔNG phải Admin, chuyển hướng thẳng đến Dashboard cá nhân
            if (role != "Admin")
            {
                // Hành động này đảm bảo nhân viên không bị chặn lỗi 
                // và được đưa đến trang dành cho họ.
                return RedirectToAction("DashboardUser");
            }

            // --- LOGIC CHO ADMIN CHÍNH THỨC BẮT ĐẦU TỪ ĐÂY ---
            ViewBag.Username = Session["TenDangNhap"].ToString().ToLower();
            var db = new DB();

            // Tổng số liệu
            int totalNV = db.dsNhanVien.Count;
            int totalHD = db.dsHopDong.Count;

            // Lấy HĐ mới nhất theo mỗi NV để tính tổng lương hiện tại
            var latestContracts = db.dsHopDong
                .GroupBy(h => h.IDNhanVIen_HopDong)
                .Select(g => g.OrderByDescending(x => x.DayToStart).FirstOrDefault())
                .Where(x => x != null)
                .ToList();

            decimal totalSalary = latestContracts.Sum(h => h.LuongCoBan_HopDong);
            decimal totalAllowances = db.dsPhuCap.Sum(p => p.SoTien_PhuCap);

            // Chart: Lương theo tháng (12 tháng gần nhất) - dựa trên HĐ bắt đầu trong tháng đó
            var labels = new List<string>();
            var values = new List<decimal>();
            var start = DateTime.Now.AddMonths(-11);

            for (int i = 0; i < 12; i++)
            {
                var month = new DateTime(start.Year, start.Month, 1).AddMonths(i);
                string label = month.ToString("MM/yyyy");
                labels.Add(label);

                decimal sumMonth = db.dsHopDong
                    .Where(h => h.DayToStart.Year == month.Year && h.DayToStart.Month == month.Month)
                    .Sum(h => h.LuongCoBan_HopDong);
                values.Add(sumMonth);
            }

            // Chart: Cơ cấu phụ cấp theo loại
            var allowanceGroups = db.dsPhuCap
                .GroupBy(p => p.Loai_PhuCap ?? "Khác")
                .Select(g => new { Loai = g.Key, Tong = g.Sum(x => x.SoTien_PhuCap) })
                .OrderByDescending(x => x.Tong)
                .ToList();

            var allowanceLabels = allowanceGroups.Select(x => x.Loai).ToList();
            var allowanceValues = allowanceGroups.Select(x => x.Tong).ToList();

            // Phòng ban và danh sách nhân viên
            var departments = db.dsPhongBan
                .OrderBy(pb => pb.NamePhongBan)
                .Select(pb => new DepartmentMembersVM
                {
                    DepartmentId = pb.IDPhongBan,
                    DepartmentName = pb.NamePhongBan,
                    Employees = db.dsNhanVien
                        .Where(nv => nv.IDPB_NhanVien == pb.IDPhongBan)
                        .OrderBy(nv => nv.FullNameNhanVien)
                        .Select(nv => new EmployeeVM
                        {
                            Id = nv.IDNhanVien,
                            Name = nv.FullNameNhanVien
                        }).ToList()
                }).ToList();

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
                Departments = departments
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

        // Thêm vào HomeController.cs

        public ActionResult DashboardUser()
        {
            if (Session["MaNV"] == null) return RedirectToAction("Login", "Login");
            int maNV = Convert.ToInt32(Session["MaNV"]);

            // Lấy số liệu cá nhân
            int thang = DateTime.Now.Month;
            int nam = DateTime.Now.Year;

            var bangCong = new BangChamCongDAO().GetByNhanVien(maNV)
                .Where(x => x.Day_ChamCong.Month == thang && x.Day_ChamCong.Year == nam).ToList();

            ViewBag.SoNgayCong = bangCong.Sum(x => x.DayCong_ChamCong);
            ViewBag.GioTangCa = bangCong.Sum(x => x.GioTangCa);

            // Kiểm tra hôm nay chấm công chưa
            ViewBag.IsCheckedIn = bangCong.Any(x => x.Day_ChamCong.Date == DateTime.Now.Date);

            return View();
        }
    }
}