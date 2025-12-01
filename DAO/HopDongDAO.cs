using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class HopDongDAO : BaseDAO
    {
        public List<HopDong> GetAll()
        {
            var list = new List<HopDong>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM HopDong ORDER BY NgayBatDau DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new HopDong()
                        {
                            IDHopDong = Convert.ToInt32(reader["MaHD"]),
                            IDNhanVIen_HopDong = Convert.ToInt32(reader["MaNV"]),
                            DayToStart = Convert.ToDateTime(reader["NgayBatDau"]),
                            DayToEnd = reader["NgayKetThuc"] != DBNull.Value ? Convert.ToDateTime(reader["NgayKetThuc"]) : (DateTime?)null,
                            Loai_HopDong = reader["LoaiHD"].ToString(),
                            LuongCoBan_HopDong = Convert.ToDecimal(reader["LuongCoBan"]),
                            Note_HopDong = reader["GhiChu"] != DBNull.Value ? reader["GhiChu"].ToString() : ""
                        });
                    }
                }
                catch { /* Log error */ }
            }
            return list;
        }

        public (bool Success, string Message) Insert(HopDong hd)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Sử dụng Procedure của Phúc để đảm bảo logic kiểm tra hợp đồng cũ
                SqlCommand cmd = new SqlCommand("sp_ThemHopDong", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaNV", hd.IDNhanVIen_HopDong);
                cmd.Parameters.AddWithValue("@NgayBatDau", hd.DayToStart);
                cmd.Parameters.AddWithValue("@NgayKetThuc", (object)hd.DayToEnd ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LoaiHD", hd.Loai_HopDong);
                cmd.Parameters.AddWithValue("@Luongcoban", hd.LuongCoBan_HopDong);
                cmd.Parameters.AddWithValue("@Ghichu", hd.Note_HopDong ?? (object)DBNull.Value);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Thêm hợp đồng thành công! Nhân viên đã được kích hoạt trạng thái Đang làm.");
                }
                catch (SqlException ex)
                {
                    // Bắt lỗi từ RAISERROR trong SQL
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }


        public List<HopDong> GetListByNhanVien(int maNV)
        {
            var list = new List<HopDong>();
            using (SqlConnection conn = GetConnection())
            {
                // Lấy hợp đồng mới nhất lên đầu
                string query = "SELECT * FROM HopDong WHERE MaNV = @MaNV ORDER BY NgayBatDau DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", maNV);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new HopDong()
                        {
                            IDHopDong = Convert.ToInt32(reader["MaHD"]),
                            IDNhanVIen_HopDong = Convert.ToInt32(reader["MaNV"]),
                            DayToStart = Convert.ToDateTime(reader["NgayBatDau"]),
                            // Kiểm tra DBNull cho ngày kết thúc
                            DayToEnd = reader["NgayKetThuc"] != DBNull.Value ? Convert.ToDateTime(reader["NgayKetThuc"]) : (DateTime?)null,
                            Loai_HopDong = reader["LoaiHD"].ToString(),
                            LuongCoBan_HopDong = Convert.ToDecimal(reader["LuongCoBan"]),
                            Note_HopDong = reader["GhiChu"] != DBNull.Value ? reader["GhiChu"].ToString() : ""
                        });
                    }
                }
                catch (Exception ex) { /* Log lỗi nếu cần */ }
            }
            return list;
        }

        // --- BỔ SUNG VÀO HopDongDAO.cs ---

        // 1. Lấy hợp đồng theo ID (để hiển thị lên form sửa)
        public HopDong GetById(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM HopDong WHERE MaHD = @MaHD";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaHD", id);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        return new HopDong()
                        {
                            IDHopDong = Convert.ToInt32(reader["MaHD"]),
                            IDNhanVIen_HopDong = Convert.ToInt32(reader["MaNV"]),
                            DayToStart = Convert.ToDateTime(reader["NgayBatDau"]),
                            DayToEnd = reader["NgayKetThuc"] != DBNull.Value ? Convert.ToDateTime(reader["NgayKetThuc"]) : (DateTime?)null,
                            Loai_HopDong = reader["LoaiHD"].ToString(),
                            LuongCoBan_HopDong = Convert.ToDecimal(reader["LuongCoBan"]),
                            Note_HopDong = reader["GhiChu"] != DBNull.Value ? reader["GhiChu"].ToString() : ""
                        };
                    }
                }
                catch { }
            }
            return null;
        }

        // 2. Cập nhật hợp đồng
        public (bool Success, string Message) Update(HopDong hd)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Lưu ý: Không cho phép sửa Mã NV (để tránh sai lệch dữ liệu lịch sử)
                string query = @"UPDATE HopDong 
                       SET NgayBatDau = @NgayBatDau, 
                           NgayKetThuc = @NgayKetThuc, 
                           LoaiHD = @LoaiHD, 
                           LuongCoBan = @LuongCoBan, 
                           GhiChu = @GhiChu 
                       WHERE MaHD = @MaHD";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaHD", hd.IDHopDong);
                cmd.Parameters.AddWithValue("@NgayBatDau", hd.DayToStart);
                cmd.Parameters.AddWithValue("@NgayKetThuc", (object)hd.DayToEnd ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@LoaiHD", hd.Loai_HopDong);
                cmd.Parameters.AddWithValue("@LuongCoBan", hd.LuongCoBan_HopDong);
                cmd.Parameters.AddWithValue("@GhiChu", hd.Note_HopDong ?? (object)DBNull.Value);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Cập nhật hợp đồng thành công!");
                }
                catch (SqlException ex)
                {
                    return (false, "Lỗi SQL: " + ex.Message);
                }
            }
        }

        // 3. Xóa hợp đồng
        public (bool Success, string Message) Delete(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "DELETE FROM HopDong WHERE MaHD = @MaHD";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaHD", id);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Đã xóa hợp đồng!");
                }
                catch (SqlException ex)
                {
                    // Bắt lỗi khóa ngoại (nếu hợp đồng đã được dùng để tính lương)
                    if (ex.Number == 547)
                        return (false, "Không thể xóa: Hợp đồng này đã được sử dụng để tính lương.");

                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }
    }
}