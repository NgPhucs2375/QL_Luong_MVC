using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class ThuongPhat
    {
        public int IDThuongPhat { get; set; }
        public int IDNhanVien_ThuongPhat { get; set; }
        public string Loai_ThuongPhat { get; set; }
        public decimal SoTien_ThuongPhat { get; set; }
        public string LyDo_ThuongPhat { get; set; }
        public int Thangg { get; set; }
        public int Namm { get; set; }
    }
}