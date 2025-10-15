using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class TaiKhoan
    {
        public string TenDangNhap {  get; set; }
        public string MatKhau { get; set; }
        public int IDNhanVien_TaiKhoan { get; set; }
        public string Quyen_TaiKhoan { get; set; }

    }
}