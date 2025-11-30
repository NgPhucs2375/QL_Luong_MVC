using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class BangLuong
    {
        public int IDBangLuong {  get; set; }
        public int IDNhanVien_BangLuong { get; set; }
        public int Month {  get; set; }
        public int Nam { get; set; }
        public decimal LuongCoBan_BangLuong { get; set; }
        public decimal TongPhuCap {  get; set; }
        public decimal TongThuongPhat {  get; set; }
        public decimal TongGioTangCa { get; set; }
        public object LuongThucNhan_BangLuong { get; internal set; }
    }
}