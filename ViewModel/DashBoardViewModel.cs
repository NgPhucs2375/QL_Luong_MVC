using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.ViewModel
{
    public class DashBoardViewModel
    {
        // KPI
        public int TotalEmployees { get; set; }
        public int TotalContracts { get; set; }
        public decimal TotalSalary { get; set; }        // Tổng lương cơ bản hiện tại (theo HĐ mới nhất của mỗi NV)
        public decimal TotalAllowances { get; set; }

        // Charts
        public List<string> SalaryByMonthLabels { get; set; } = new List<string>();   // "MM/yyyy"
        public List<decimal> SalaryByMonthValues { get; set; } = new List<decimal>(); // Tổng lương theo tháng

        public List<string> AllowanceLabels { get; set; } = new List<string>();       // Loại phụ cấp
        public List<decimal> AllowanceValues { get; set; } = new List<decimal>();     // Tổng tiền theo loại

        // Phòng ban và danh sách nhân viên
        public List<DepartmentMembersVM> Departments { get; set; } = new List<DepartmentMembersVM>();
    }

    public class DepartmentMembersVM
    {
        public int DepartmentId { get; set; }
        public string DepartmentName { get; set; }
        public List<EmployeeVM> Employees { get; set; } = new List<EmployeeVM>();
        public int Count => Employees?.Count ?? 0;
    }

    public class EmployeeVM
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}