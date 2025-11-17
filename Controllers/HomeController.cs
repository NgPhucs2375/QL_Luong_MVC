using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using QL_Luong_MVC.Models;
using QL_Luong_MVC.ViewModel;

namespace QL_Luong_MVC.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            // ✅ Kiểm tra đăng nhập
            if (Session["TenDangNhap"] == null)
                return RedirectToAction("Login", "Login");

            // ✅ Kiểm tra quyền
            string username = Session["TenDangNhap"].ToString().ToLower();
            string role = Session["Quyen"]?.ToString();

            if (username != "admin" && role != "Admin")
            {
                TempData["Error"] = "Bạn không có quyền truy cập trang này!";
                return RedirectToAction("AccessDenied", "Login");
            }

            ViewBag.Username = username;

            // ✅ Tạo dữ liệu Dashboard
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
    }
}