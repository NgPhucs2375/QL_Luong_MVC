using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class BangChamCong
    {
        public int IDChamCong   { get; set; }
        public int IDNhanVien_ChamCong { get; set; }
        public DateTime Day_ChamCong { get; set; }
        public decimal DayCong_ChamCong { get; set; }
        public decimal GioTangCa {  get; set; }
    }
}