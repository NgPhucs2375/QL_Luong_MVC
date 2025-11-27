using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class PhongBanDAO : BaseDAO
    {
        // Lấy tất cả phòng ban
        public List<PhongBan> GetAll()
        {
            var list = new List<PhongBan>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM PhongBan";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new PhongBan()
                        {
                            IDPhongBan = Convert.ToInt32(reader["MaPB"]),
                            NamePhongBan = reader["TenPB"].ToString(),
                            DateOf_Establishment = reader["NgayThanhLap"] != DBNull.Value ? Convert.ToDateTime(reader["NgayThanhLap"]) : DateTime.MinValue
                        });
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Lỗi GetAll PB: " + ex.Message);
                }
            }
            return list;
        }

        // Lấy 1 phòng ban theo ID
        public PhongBan GetById(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM PhongBan WHERE MaPB = @MaPB";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaPB", id);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        return new PhongBan()
                        {
                            IDPhongBan = Convert.ToInt32(reader["MaPB"]),
                            NamePhongBan = reader["TenPB"].ToString(),
                            DateOf_Establishment = reader["NgayThanhLap"] != DBNull.Value ? Convert.ToDateTime(reader["NgayThanhLap"]) : DateTime.MinValue
                        };
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Lỗi GetById PB: " + ex.Message);
                }
            }
            return null;
        }

        // Thêm mới (Dùng SP sp_QuanLyPhongBan)
        public (bool Success, string Message) Insert(PhongBan pb)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_QuanLyPhongBan", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ThaoTac", "THEM");
                cmd.Parameters.AddWithValue("@TenPB", pb.NamePhongBan);
                // MaPB tự tăng nên không cần truyền hoặc truyền NULL nếu SP yêu cầu

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Thêm phòng ban thành công!");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }

        // Cập nhật
        public (bool Success, string Message) Update(PhongBan pb)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_QuanLyPhongBan", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ThaoTac", "SUA");
                cmd.Parameters.AddWithValue("@MaPB", pb.IDPhongBan);
                cmd.Parameters.AddWithValue("@TenPB", pb.NamePhongBan);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Cập nhật thành công!");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }

        // Xóa
        public (bool Success, string Message) Delete(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_QuanLyPhongBan", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ThaoTac", "XOA");
                cmd.Parameters.AddWithValue("@MaPB", id);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Xóa thành công!");
                }
                catch (Exception ex) { return (false, "Lỗi (có thể do ràng buộc dữ liệu): " + ex.Message); }
            }
        }
    }
}