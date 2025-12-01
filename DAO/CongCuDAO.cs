using QL_Luong_MVC.DAO;
using System;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class CongCuDAO : BaseDAO
    {
        // Gọi SP Tăng lương hàng loạt
        public bool TangLuongHangLoat(decimal phanTram)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_TangLuongHangLoat", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PhanTramTang", phanTram);
                try { conn.Open(); cmd.ExecuteNonQuery(); return true; }
                catch { return false; }
            }
        }

        // Gọi SP Backup DB
        public bool BackupDatabase()
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_TaoBackup_QLLuong", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                try { conn.Open(); cmd.ExecuteNonQuery(); return true; }
                catch { return false; }
            }
        }
    }
}