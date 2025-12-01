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
                        });
                    }
                }
                catch(Exception ex) { System.Diagnostics.Debug.WriteLine("Lỗi DAO: " + ex.Message); }
            }
            return list;
        }

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

        public decimal GetTongTienPhuCap_TuFunction(string loaiPC = null)
        {
            decimal ketQua = 0;
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT dbo.fn_TongPhuCapLoai(@LoaiPC)";

                SqlCommand cmd = new SqlCommand(query, conn);

                if (string.IsNullOrEmpty(loaiPC))
                    cmd.Parameters.AddWithValue("@LoaiPC", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@LoaiPC", loaiPC);

                try
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        ketQua = Convert.ToDecimal(result);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Lỗi gọi fn_TongPhuCapLoai: " + ex.Message);
                }
            }
            return ketQua;
        }

        // --- BỔ SUNG VÀO PhuCapDAO.cs ---

        // 1. Lấy 1 phụ cấp theo ID (để hiển thị lên form sửa)
        public PhuCap GetById(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM PhuCap WHERE MaPC = @MaPC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaPC", id);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        return new PhuCap()
                        {
                            IDPhuCap = Convert.ToInt32(reader["MaPC"]),
                            IDNhanVien_PhuCap = Convert.ToInt32(reader["MaNV"]),
                            Loai_PhuCap = reader["LoaiPhuCap"].ToString(),
                            SoTien_PhuCap = Convert.ToDecimal(reader["SoTien"])
                        };
                    }
                }
                catch { }
            }
            return null;
        }

        // 2. Cập nhật phụ cấp
        public (bool Success, string Message) Update(PhuCap pc)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "UPDATE PhuCap SET LoaiPhuCap = @Loai, SoTien = @Tien WHERE MaPC = @MaPC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaPC", pc.IDPhuCap);
                cmd.Parameters.AddWithValue("@Loai", pc.Loai_PhuCap);
                cmd.Parameters.AddWithValue("@Tien", pc.SoTien_PhuCap);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Cập nhật thành công!");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }

        // 3. Xóa phụ cấp
        public (bool Success, string Message) Delete(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "DELETE FROM PhuCap WHERE MaPC = @MaPC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaPC", id);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Đã xóa khoản phụ cấp!");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }
    }
}