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
            // ✅ Kiểm tra đăng nhập
            if (Session["TenDangNhap"] == null)
                return RedirectToAction("Login", "Login");

            // ✅ Kiểm tra quyền
            string username = Session["TenDangNhap"].ToString().ToLower();
            string role = Session["Quyen"]?.ToString();

            // 2. LOGIC ĐIỀU HƯỚNG MỚI (FIX LỖI)
            // Nếu KHÔNG phải Admin, chuyển hướng thẳng đến Dashboard cá nhân
            if (role != "Admin")
            {
                TempData["Error"] = "Bạn không có quyền truy cập trang này!";
                return RedirectToAction("AccessDenied", "Login");
            }

            ViewBag.Username = username;
            // ✅ Tạo dữ liệu Dashboard
            var db = new DB();

            int totalNV = db.dsNhanVien.Count;
            int totalHD = db.dsHopDong.Count;

            var latestContracts = db.dsHopDong
                .GroupBy(h => h.IDNhanVIen_HopDong)
                .Select(g => g.OrderByDescending(x => x.DayToStart).FirstOrDefault())
                .Where(x => x != null)
                .ToList();

            decimal totalSalary = latestContracts.Sum(h => h.LuongCoBan_HopDong);
            decimal totalAllowances = db.dsPhuCap.Sum(p => p.SoTien_PhuCap);

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

            var allowanceGroups = db.dsPhuCap
                .GroupBy(p => p.Loai_PhuCap ?? "Khác")
                .Select(g => new { Loai = g.Key, Tong = g.Sum(x => x.SoTien_PhuCap) })
                .OrderByDescending(x => x.Tong)
                .ToList();

            var allowanceLabels = allowanceGroups.Select(x => x.Loai).ToList();
            var allowanceValues = allowanceGroups.Select(x => x.Tong).ToList();

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


        public ActionResult DashboardUser()
        {
            if (Session["MaNV"] == null) return RedirectToAction("Login", "Login");
            int idNhanVien = Convert.ToInt32(Session["MaNV"]);

            int thang = DateTime.Now.Month;
            int nam = DateTime.Now.Year;

            var bangCong = new BangChamCongDAO().GetByNhanVien(maNV)
                            .Where(x => x.Day_ChamCong.Month == thang && x.Day_ChamCong.Year == nam).ToList();

            ViewBag.SoNgayCong = bangCong.Sum(x => x.DayCong_ChamCong);
            ViewBag.GioTangCa = bangCong.Sum(x => x.GioTangCa);

            ViewBag.IsCheckedIn = bangCong.Any(x => x.Day_ChamCong.Date == DateTime.Now.Date);

            var congGanDay = new BangChamCongDAO()
                .GetByNhanVien(idNhanVien)
                .OrderByDescending(x => x.Day_ChamCong)
                .Take(10)
                .ToList();
            ViewBag.RecentActivities = congGanDay;

            var db = new DB();

            var nhanVien = db.dsNhanVien.FirstOrDefault(x => x.IDNhanVien == idNhanVien);
            
            var hopDong = db.dsHopDong
                            .Where(x => x.IDNhanVIen_HopDong == idNhanVien)
                            .OrderByDescending(x => x.DayToStart)
                            .FirstOrDefault();

            var luongGanNhat = new BangLuongDAO()
                                 .GetByNhanVien(idNhanVien)
                                 .FirstOrDefault();

            ViewBag.NhanVien = nhanVien;
            ViewBag.HopDong = hopDong;
            ViewBag.LuongGanNhat = luongGanNhat;

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
            bool daChamCong = listCong.Any(x => x.Day_ChamCong.Date == DateTime.Now.Date);

            if (daChamCong)
            {
                TempData["Message"] = "Hôm nay bạn đã chấm công rồi!";
                TempData["Type"] = "warning";
                return RedirectToAction("DashboardUser");
            }

            BangChamCong bcc = new BangChamCong
            {
                IDNhanVien_ChamCong = maNV,
                Day_ChamCong = DateTime.Now,
                DayCong_ChamCong = 1,
                GioTangCa = 0
            };

            var insertResult = dao.Insert(bcc);
            if (insertResult.Success)
            {
                TempData["Message"] = insertResult.Message ?? "Chấm công thành công!";
                TempData["Type"] = "success";
            }
            else
            {
                TempData["Message"] = insertResult.Message ?? "Có lỗi xảy ra, vui lòng thử lại!";
                TempData["Type"] = "danger";
            }

            return RedirectToAction("DashboardUser");
        }
    }
}