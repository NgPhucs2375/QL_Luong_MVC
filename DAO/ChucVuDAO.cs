using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class ChucVuDAO : BaseDAO
    {
        public List<ChucVu> GetAll()
        {
            List<ChucVu> list = new List<ChucVu>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM ChucVu";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new ChucVu()
                        {
                            IDChucVu = Convert.ToInt32(reader["MaCV"]),
                            NameChucVu = reader["TenCV"].ToString(),
                            HeSoLuong_ChucVu = reader["HeSoLuong"] != DBNull.Value ? Convert.ToDecimal(reader["HeSoLuong"]) : 0
                        });
                    }
                }
                catch (Exception ex)
                {
                    // Ghi log lỗi nếu cần
                    System.Diagnostics.Debug.WriteLine("Lỗi GetAll CV: " + ex.Message);
                }
            }
            return list;
        }
    }
}