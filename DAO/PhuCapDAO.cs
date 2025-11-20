using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class PhuCapDAO : BaseDAO
    {
        public List<PhuCap> GetAll()
        {
            var list = new List<PhuCap>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM PhuCap";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new PhuCap()
                        {
                            IDPhuCap = Convert.ToInt32(reader["MaPC"]),
                            IDNhanVien_PhuCap = Convert.ToInt32(reader["MaNV"]),
                            Loai_PhuCap = reader["LoaiPhuCap"].ToString(),
                            SoTien_PhuCap = Convert.ToDecimal(reader["SoTien"])
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // Lấy danh sách phụ cấp của riêng 1 nhân viên
        public List<PhuCap> GetByNhanVienId(int maNV)
        {
            var list = new List<PhuCap>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM PhuCap WHERE MaNV = @MaNV";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", maNV);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new PhuCap()
                        {
                            IDPhuCap = Convert.ToInt32(reader["MaPC"]),
                            IDNhanVien_PhuCap = Convert.ToInt32(reader["MaNV"]),
                            Loai_PhuCap = reader["LoaiPhuCap"].ToString(),
                            SoTien_PhuCap = Convert.ToDecimal(reader["SoTien"]),
                            // GhiChu có thể chưa có trong model PhuCap của bạn, nếu có thì thêm vào
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // Tính tổng tiền phụ cấp (Dùng Function SQL fn_TongPhuCap_NV)
        public decimal GetTotalByNhanVienId(int maNV)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT dbo.fn_TongPhuCap_NV(@MaNV)";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", maNV);
                try
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                }
                catch { return 0; }
            }
        }

        public (bool Success, string Message) Insert(PhuCap pc)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_ThemPhuCap", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MaNV", pc.IDNhanVien_PhuCap);
                cmd.Parameters.AddWithValue("@LoaiPhuCap", pc.Loai_PhuCap);
                cmd.Parameters.AddWithValue("@SoTien", pc.SoTien_PhuCap);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Thêm phụ cấp thành công!");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }
    }
}