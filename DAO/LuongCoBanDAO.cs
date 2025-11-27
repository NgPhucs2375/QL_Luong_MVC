using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class LuongCoBanDAO : BaseDAO
    {
        public List<LuongCoban> GetAll()
        {
            var list = new List<LuongCoban>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM LuongCoBan";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new LuongCoban()
                        {
                            IDLuongCoBan = Convert.ToInt32(reader["MaLCB"]),
                            IDChucVu_LuongCB = Convert.ToInt32(reader["MaCV"]),
                            MucLuong = Convert.ToDecimal(reader["MucLuong"])
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        public LuongCoban GetById(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM LuongCoBan WHERE MaLCB = @MaLCB";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaLCB", id);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        return new LuongCoban()
                        {
                            IDLuongCoBan = Convert.ToInt32(reader["MaLCB"]),
                            IDChucVu_LuongCB = Convert.ToInt32(reader["MaCV"]),
                            MucLuong = Convert.ToDecimal(reader["MucLuong"])
                        };
                    }
                }
                catch { }
            }
            return null;
        }

        // Hàm xử lý chung cho Thêm/Sửa/Xóa dùng Procedure
        public (bool Success, string Message) ExecuteAction(string action, LuongCoban item)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_QuanLyLuongCoBan", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@HanhDong", action); // "Thêm", "Sửa", "Xóa"
                cmd.Parameters.AddWithValue("@MaCV", item.IDChucVu_LuongCB);

                // Chỉ truyền mức lương nếu không phải xóa
                if (action != "Xóa")
                    cmd.Parameters.AddWithValue("@MucLuong", item.MucLuong);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    string msg = action == "Thêm" ? "Thêm mới thành công!" : (action == "Sửa" ? "Cập nhật thành công!" : "Xóa thành công!");
                    return (true, msg);
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }
    }
}