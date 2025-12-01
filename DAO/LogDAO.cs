using QL_Luong_MVC.Models;
using QL_Luong_MVC.ViewModel;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class LogDAO : BaseDAO
    {
        // 1. Lấy log sửa chấm công
        public List<LogChamCongVM> GetLogChamCong()
        {
            var list = new List<LogChamCongVM>();
            using (SqlConnection conn = GetConnection())
            {
                // Lấy 50 dòng mới nhất
                string sql = "SELECT TOP 50 * FROM Log_ChamCong ORDER BY ThoiGian DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new LogChamCongVM
                        {
                            LogID = Convert.ToInt32(reader["LogID"]),
                            HanhDong = reader["HanhDong"].ToString(),
                            MaNV = Convert.ToInt32(reader["MaNV"]),
                            NgayChamCong = Convert.ToDateTime(reader["Ngay"]),
                            // Kiểm tra DBNull cho các trường số
                            NgayCong_Cu = reader["NgayCong_Cu"] != DBNull.Value ? (decimal?)reader["NgayCong_Cu"] : null,
                            NgayCong_Moi = reader["NgayCong_Moi"] != DBNull.Value ? (decimal?)reader["NgayCong_Moi"] : null,
                            GioTangCa_Cu = reader["GioTangCa_Cu"] != DBNull.Value ? (decimal?)reader["GioTangCa_Cu"] : null,
                            GioTangCa_Moi = reader["GioTangCa_Moi"] != DBNull.Value ? (decimal?)reader["GioTangCa_Moi"] : null,
                            ThoiGianThucHien = Convert.ToDateTime(reader["ThoiGian"]),
                            NguoiThucHien = reader["NguoiThucHien"].ToString()
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // 2. Lấy log xóa nhân viên
        public List<LogXoaNhanVienVM> GetLogXoaNV()
        {
            var list = new List<LogXoaNhanVienVM>();
            using (SqlConnection conn = GetConnection())
            {
                string sql = "SELECT * FROM LichSuXoaNhanVien ORDER BY NgayXoa DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new LogXoaNhanVienVM
                        {
                            MaNV = Convert.ToInt32(reader["MaNV"]),
                            HoTen = reader["HoTen"].ToString(),
                            NgayXoa = Convert.ToDateTime(reader["NgayXoa"]),
                            LyDo = reader["LyDo"].ToString()
                        });
                    }
                }
                catch { }
            }
            return list;
        }
    }
}