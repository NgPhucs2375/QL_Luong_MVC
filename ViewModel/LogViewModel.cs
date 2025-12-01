using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.ViewModel
{
    public class LogChamCongVM
    {
        public int LogID { get; set; }
        public string HanhDong { get; set; } // INSERT, UPDATE, DELETE
        public int MaNV { get; set; }
        public DateTime NgayChamCong { get; set; }
        public decimal? NgayCong_Cu { get; set; }
        public decimal? NgayCong_Moi { get; set; }
        public decimal? GioTangCa_Cu { get; set; }
        public decimal? GioTangCa_Moi { get; set; }
        public DateTime ThoiGianThucHien { get; set; }
        public string NguoiThucHien { get; set; }
    }
    public class LogXoaNhanVienVM
    {
        public int MaNV { get; set; }
        public string HoTen { get; set; }
        public DateTime NgayXoa { get; set; }
        public string LyDo { get; set; }
    }

    public class SystemLogViewModel
    {
        public System.Collections.Generic.List<LogChamCongVM> LogsChamCong { get; set; }
        public System.Collections.Generic.List<LogXoaNhanVienVM> LogsXoaNV { get; set; }
    }
}