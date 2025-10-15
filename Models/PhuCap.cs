using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class PhuCap
    {

        public int IDPhuCap {  get; set; }
        public int IDNhanVien_PhuCap { get; set; }
        public string Loai_PhuCap { get; set; }
        public decimal SoTien_PhuCap { get; set; }


    }
}