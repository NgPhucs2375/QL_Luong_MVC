using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class HopDong
    {

        public int IDHopDong { get; set; }
        public int IDNhanVIen_HopDong { get; set; }
        public DateTime DayToStart { get; set; }
        public DateTime? DayToEnd { get; set; }
        public string Loai_HopDong { get; set; }
        public decimal LuongCoBan_HopDong { get; set; }
        public string Note_HopDong { get; set; }


    }
}