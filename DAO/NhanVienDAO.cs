using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class NhanVienDAO : BaseDAO
    {
        // --- 1. Lấy danh sách nhân viên ---
        public List<NhanVien> GetAll()
        {
            List<NhanVien> list = new List<NhanVien>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM NhanVien";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(MapData(reader));
                    }
                }
                catch (Exception ex) { throw new Exception("Lỗi GetAll NV: " + ex.Message); }
            }
            return list;
        }

        // --- 2. Lấy 1 nhân viên theo ID ---
        public NhanVien GetById(int id)
        {
            NhanVien nv = null;
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM NhanVien WHERE MaNV = @MaNV";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", id);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        nv = MapData(reader);
                    }
                }
                catch (Exception ex) { throw new Exception("Lỗi GetById NV: " + ex.Message); }
            }
            return nv;
        }

        // --- 3. Thêm mới (Trả về Tuple: bool Success, string Message) ---
        public (bool Success, string Message) Insert(NhanVien nv)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Sử dụng Procedure sp_AddNhanVien
                SqlCommand cmd = new SqlCommand("sp_AddNhanVien", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@HoTen", nv.FullNameNhanVien);
                cmd.Parameters.AddWithValue("@NgaySinh", nv.DayOfBirth_NhanVien);
                cmd.Parameters.AddWithValue("@GioiTinh", nv.Sex_NhanVien);
                cmd.Parameters.AddWithValue("@DiaChi", nv.Address_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@DienThoai", nv.SDT_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Email", nv.Email_NhanVien ?? (object)DBNull.Value);
                // Xử lý giá trị 0 hoặc null cho khóa ngoại
                cmd.Parameters.AddWithValue("@MaPB", nv.IDPB_NhanVien == 0 ? (object)DBNull.Value : nv.IDPB_NhanVien);
                cmd.Parameters.AddWithValue("@MaCV", nv.IDCV_NhanVien == 0 ? (object)DBNull.Value : nv.IDCV_NhanVien);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Thêm thành công!");
                }
                catch (SqlException ex)
                {
                    return (false, "Lỗi SQL: " + ex.Message);
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi hệ thống: " + ex.Message);
                }
            }
        }

        // --- 4. Cập nhật (Trả về Tuple) ---
        public (bool Success, string Message) Update(NhanVien nv)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = @"UPDATE NhanVien SET 
                                HoTen=@HoTen, GioiTinh=@GioiTinh, NgaySinh=@NgaySinh,
                                DiaChi=@DiaChi, DienThoai=@DienThoai, Email=@Email,
                                TrangThai=@TrangThai, MaCV=@MaCV, MaPB=@MaPB
                                WHERE MaNV=@MaNV";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", nv.IDNhanVien);
                cmd.Parameters.AddWithValue("@HoTen", nv.FullNameNhanVien);
                cmd.Parameters.AddWithValue("@GioiTinh", nv.Sex_NhanVien);
                cmd.Parameters.AddWithValue("@NgaySinh", nv.DayOfBirth_NhanVien);
                cmd.Parameters.AddWithValue("@DiaChi", nv.Address_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@DienThoai", nv.SDT_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Email", nv.Email_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@TrangThai", nv.State_NhanVien ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@MaCV", nv.IDCV_NhanVien == 0 ? (object)DBNull.Value : nv.IDCV_NhanVien);
                cmd.Parameters.AddWithValue("@MaPB", nv.IDPB_NhanVien == 0 ? (object)DBNull.Value : nv.IDPB_NhanVien);

                try
                {
                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();
                    return rows > 0 ? (true, "Cập nhật thành công!") : (false, "Không tìm thấy nhân viên.");
                }
                catch (Exception ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }

        // --- 5. Xóa (Trả về Tuple) ---
        public (bool Success, string Message) Delete(int id)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "DELETE FROM NhanVien WHERE MaNV = @MaNV";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", id);

                try
                {
                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();
                    return rows > 0 ? (true, "Xóa thành công!") : (false, "Không tìm thấy nhân viên.");
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("REFERENCE"))
                        return (false, "Không thể xóa: Nhân viên này đang có dữ liệu lương/hợp đồng.");
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }

        // Helper: Map dữ liệu từ SQL Reader sang Object Model
        private NhanVien MapData(SqlDataReader reader)
        {
            var nv = new NhanVien
            {
                IDNhanVien = Convert.ToInt32(reader["MaNV"]),
                FullNameNhanVien = reader["HoTen"].ToString(),
                DayOfBirth_NhanVien = reader["NgaySinh"] != DBNull.Value ? Convert.ToDateTime(reader["NgaySinh"]) : DateTime.MinValue,
                Sex_NhanVien = reader["GioiTinh"].ToString(),
                Address_NhanVien = reader["DiaChi"].ToString(),
                SDT_NhanVien = reader["DienThoai"].ToString(),
                Email_NhanVien = reader["Email"].ToString(),
                State_NhanVien = reader["TrangThai"].ToString(),
                IDCV_NhanVien = reader["MaCV"] != DBNull.Value ? Convert.ToInt32(reader["MaCV"]) : 0,
                IDPB_NhanVien = reader["MaPB"] != DBNull.Value ? Convert.ToInt32(reader["MaPB"]) : 0,
                LuongHienTai = reader["LuongHienTai"] != DBNull.Value ? Convert.ToDecimal(reader["LuongHienTai"]) : 0
            };

            // Kiểm tra cột LuongHienTai (nếu có trong DB)
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (reader.GetName(i).Equals("LuongHienTai", StringComparison.InvariantCultureIgnoreCase))
                {
                    // Uncomment dòng dưới nếu Model NhanVien đã có thuộc tính LuongHienTai
                    // nv.LuongHienTai = reader["LuongHienTai"] != DBNull.Value ? Convert.ToDecimal(reader["LuongHienTai"]) : 0;
                }
            }
            return nv;
        }
    }
}