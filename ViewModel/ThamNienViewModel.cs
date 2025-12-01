using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.ViewModel
{
    public class ThamNienViewModel
    {
        public int MaNV { get; set; }
        public string HoTen { get; set; }
        public string TenPB { get; set; }
        public string TenCV { get; set; }
        public DateTime NgayGiaNhap { get; set; }
        public int SoThangLamViec { get; set; }
        public string CapDo { get; set; }
        public decimal ThuongDeXuat { get; set; }

        public string HienThiThoiGian
        {
            get
            {
                int nam = SoThangLamViec / 12;
                int thang = SoThangLamViec % 12;
                if (nam > 0) return $"{nam} năm {thang} tháng";
                return $"{thang} tháng";
            }
        }
    }
}