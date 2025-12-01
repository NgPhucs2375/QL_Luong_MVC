using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class ThuongPhatDAO : BaseDAO
    {
        // Lấy danh sách thưởng phạt theo tháng/năm
        public List<ThuongPhat> GetByMonth(int thang, int nam)
        {
            var list = new List<ThuongPhat>();
            using (SqlConnection conn = GetConnection())
            {
                string sql = "SELECT * FROM ThuongPhat WHERE Thangg = @Thang AND Namm = @Nam ORDER BY MaTP DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Thang", thang);
                cmd.Parameters.AddWithValue("@Nam", nam);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new ThuongPhat
                        {
                            IDThuongPhat = Convert.ToInt32(reader["MaTP"]),
                            IDNhanVien_ThuongPhat = Convert.ToInt32(reader["MaNV"]),
                            Thangg = Convert.ToInt32(reader["Thangg"]),
                            Namm = Convert.ToInt32(reader["Namm"]),
                            Loai_ThuongPhat = reader["Loai"].ToString(),
                            SoTien_ThuongPhat = Convert.ToDecimal(reader["SoTien"]),
                            LyDo_ThuongPhat = reader["LyDo"].ToString()
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // Gọi SP để thêm và tự động update bảng lương
        public (bool Success, string Message) Insert(ThuongPhat tp)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_ThemThuongPhat_AndCapNhatBangLuong", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaNV", tp.IDNhanVien_ThuongPhat);
                cmd.Parameters.AddWithValue("@Loai", tp.Loai_ThuongPhat);
                cmd.Parameters.AddWithValue("@SoTien", tp.SoTien_ThuongPhat);
                cmd.Parameters.AddWithValue("@LyDo", tp.LyDo_ThuongPhat ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Thangg", tp.Thangg);
                cmd.Parameters.AddWithValue("@Namm", tp.Namm);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Đã thêm và cập nhật bảng lương thành công!");
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }

        public bool Delete(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Lưu ý: Nếu xóa thưởng phạt, bạn nên có Trigger Update lại lương (trong DB hiện tại chưa có trigger xóa, cần lưu ý)
                string sql = "DELETE FROM ThuongPhat WHERE MaTP = @ID";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                return cmd.ExecuteNonQuery() > 0;
            }
        }
    }
}