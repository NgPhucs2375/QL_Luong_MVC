using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class NhanVien
    {

        public int IDNhanVien { get; set; }
        public string FullNameNhanVien { get; set; }
        public DateTime DayOfBirth_NhanVien { get; set; }
        public string Sex_NhanVien { get; set; }
        public string Address_NhanVien { get; set; }
        public string SDT_NhanVien { get; set; }
        public string Email_NhanVien { get; set; }
        public string State_NhanVien { get; set; }
        public int IDCV_NhanVien { get; set; }
        public int IDPB_NhanVien { get; set; }
        public decimal LuongHienTai { get; set; }

    }
}