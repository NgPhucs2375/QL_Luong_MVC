using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class DB
    {
        //Link DB
        static string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        SqlConnection con = new SqlConnection(strcon);

        // Init các danh sách  
        public List<NhanVien> dsNhanVien = new List<NhanVien>();
        public List<PhongBan> dsPhongBan = new List<PhongBan>();
        public List<ChucVu> dsChucVu = new List<ChucVu>();
        public List<HopDong> dsHopDong = new List<HopDong>();
        public List<BangChamCong> dsBangChamCong = new List<BangChamCong>();
        public List<PhuCap> dsPhuCap = new List<PhuCap>();
        public List<ThuongPhat> dsThuongPhat = new List<ThuongPhat>();
        public List<LuongCoban> dsLuongCoban = new List<LuongCoban>();
        public List<BangLuong> dsBangLuong = new List<BangLuong>();
        public List<TaiKhoan> dsTaiKhoan = new List<TaiKhoan>();


      // Constructor
        public DB()
        {
            Lap_ListNhanVien();
            Lap_ListPhongBan();
            Lap_ListChucVu();
            Lap_ListLuongCoBan();


        }

        // Hàm 
        public void Lap_ListNhanVien()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From NhanVien", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new NhanVien();
                t.IDNhanVien = int.Parse(dr["MaNV"].ToString());
                t.FullNameNhanVien = dr["HoTen"].ToString();
                t.DayOfBirth_NhanVien = DateTime.Parse(dr["NgaySinh"].ToString());
                t.Sex_NhanVien = dr["GioiTinh"].ToString();
                t.Address_NhanVien = dr["DiaChi"].ToString();
                t.SDT_NhanVien = dr["DienThoai"].ToString();
                t.Email_NhanVien = dr["Email"].ToString();
                t.State_NhanVien = dr["TrangThai"].ToString();
                t.IDCV_NhanVien= int.Parse(dr["MaCV"].ToString());
                t.IDPB_NhanVien = int.Parse(dr["MaPB"].ToString());
                dsNhanVien.Add(t);
            }
        }

        public void Lap_ListPhongBan()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From PhongBan", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new PhongBan();

                t.IDPhongBan = int.Parse(dr["MaPB"].ToString());
                t.NamePhongBan = dr["TenPB"].ToString();
                t.DateOf_Establishment = DateTime.Parse(dr["NgayThanhLap"].ToString());
                dsPhongBan.Add(t);
            }
        }

        public void Lap_ListChucVu()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From ChucVu", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new ChucVu();

                t.IDChucVu = int.Parse(dr["MaCV"].ToString());
                t.NameChucVu = dr["TenCV"].ToString();
                t.HeSoLuong_ChucVu = decimal.Parse(dr["HeSoLuong"].ToString());
                dsChucVu.Add(t);
            }
        }

        public void Lap_ListLuongCoBan()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From LuongCoban", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new LuongCoban();

                t.IDLuongCoBan= int.Parse(dr["MaLCB"].ToString());
                t.IDChucVu_LuongCB = int.Parse(dr["MaCV"].ToString());
                t.MucLuong = decimal.Parse(dr["MucLuong"].ToString());
                dsLuongCoban.Add(t);
            }
        }


        // Hàm thêm Hợp đồng
        // =========================
        // UC5 - Thêm hợp đồng mới
        // =========================
        public bool ThemHopDong(HopDong hd)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_ThemHopDong", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaNV", hd.IDNhanVIen_HopDong);
                    cmd.Parameters.AddWithValue("@NgayBatDau", hd.DayToStart);
                    cmd.Parameters.AddWithValue("@NgayKetThuc", hd.DayToEnd);
                    cmd.Parameters.AddWithValue("@LoaiHopDong", hd.Loai_HopDong);
                    cmd.Parameters.AddWithValue("@LuongCoBan", hd.LuongCoBan_HopDong);
                    cmd.Parameters.AddWithValue("@GhiChu", hd.Note_HopDong ?? (object)DBNull.Value);

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi thêm hợp đồng: " + ex.Message);
                return false;
            }
        }


        // Hàm Thêm phụ cấp 
        // =========================
        // UC9 - Thêm phụ cấp mới
        // =========================
        public bool ThemPhuCap(PhuCap pc)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_ThemPhuCap", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaNV", pc.IDNhanVien_PhuCap);
                    cmd.Parameters.AddWithValue("@LoaiPhuCap", pc.Loai_PhuCap);
                    cmd.Parameters.AddWithValue("@SoTien", pc.SoTien_PhuCap);

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi thêm phụ cấp: " + ex.Message);
                return false;
            }
        }


        // Hàm tính tổng phụ cấp của nhân viên
        // =========================
        // UC10 - Tính tổng phụ cấp nhân viên
        // =========================
        public decimal TongPhuCapNhanVien(int maNV)
        {
            decimal tong = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT dbo.fn_TongPhuCap_NV(@MaNV)", con);
                    cmd.Parameters.AddWithValue("@MaNV", maNV);

                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        tong = Convert.ToDecimal(result);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi tính tổng phụ cấp: " + ex.Message);
            }
            return tong;
        }




    }
}