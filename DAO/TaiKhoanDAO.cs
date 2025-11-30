using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class TaiKhoanDAO : BaseDAO
    {
        // Kiểm tra đăng nhập
        public LoginResult CheckLogin(string username, string password)
        {
            using (SqlConnection conn = GetConnection())
            {
                try
                {
                    // Hardcode Admin tối thượng
                    if (username.ToLower() == "admin" && password == "123456")
                        return new LoginResult { Success = true, Role = "Admin", MaNV = 0 };

                    string query = "SELECT * FROM TaiKhoan WHERE TenDangNhap=@user AND MatKhau=@pass";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@user", username);
                    cmd.Parameters.AddWithValue("@pass", password); // Nên hash password ở đây nếu có

                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        return new LoginResult
                        {
                            Success = true,
                            Role = dr["Quyen"].ToString(),
                            MaNV = dr["MaNV"] != DBNull.Value ? (int?)dr["MaNV"] : null
                        };
                    }
                    return new LoginResult { Success = false, Message = "Sai tên đăng nhập hoặc mật khẩu." };
                }
                catch (Exception ex)
                {
                    return new LoginResult { Success = false, Message = "Lỗi hệ thống: " + ex.Message };
                }
            }
        }

        // Đăng ký tài khoản mới
        public (bool Success, string Message) Register(string username, string password, int maNV)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Sử dụng Procedure sp_TaoTaiKhoan
                SqlCommand cmd = new SqlCommand("sp_TaoTaiKhoan", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TenDangNhap", username);
                cmd.Parameters.AddWithValue("@MatKhau", password);
                cmd.Parameters.AddWithValue("@MaNV", maNV);
                cmd.Parameters.AddWithValue("@Quyen", "User");
                // Default Role ID 4 = NhanVien
                cmd.Parameters.AddWithValue("@MaRole", 4);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Đăng ký thành công!");
                }
                catch (SqlException ex)
                {
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }

        // Lấy danh sách tài khoản (Cho Admin quản lý)
        public List<TaiKhoan> GetAll()
        {
            var list = new List<TaiKhoan>();
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM TaiKhoan";
                SqlCommand cmd = new SqlCommand(query, conn);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new TaiKhoan()
                        {
                            TenDangNhap = reader["TenDangNhap"].ToString(),
                            IDNhanVien_TaiKhoan = reader["MaNV"] != DBNull.Value ? Convert.ToInt32(reader["MaNV"]) : 0,
                            Quyen_TaiKhoan = reader["Quyen"].ToString()
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // Cấp/Hủy quyền Admin
        public bool UpdateRole(string username, string roleName)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Cập nhật cả cột Quyen và MaRole để đồng bộ
                string query = @"UPDATE TaiKhoan 
                               SET Quyen = @RoleName, 
                                   MaRole = (SELECT MaRole FROM Roles WHERE TenRole = @RoleName) 
                               WHERE TenDangNhap = @User";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RoleName", roleName);
                cmd.Parameters.AddWithValue("@User", username);

                try
                {
                    conn.Open();
                    return cmd.ExecuteNonQuery() > 0;
                }
                catch { return false; }
            }
        }

        public (bool Success, string Message) ChangePassword(string username, string oldPassword, string newPassword)
        {
            using (SqlConnection conn = GetConnection())
            {
                try
                {
                    // BƯỚC 1: KIỂM TRA MẬT KHẨU CŨ CÓ ĐÚNG KHÔNG (Sử dụng CheckLogin logic)
                    // Lưu ý: KHÔNG nên hash mật khẩu mới trong DAO, nên hash trong Controller nếu có logic hash.
                    var checkOldPass = CheckLogin(username, oldPassword);

                    if (!checkOldPass.Success)
                    {
                        return (false, "❌ Mật khẩu cũ không đúng.");
                    }

                    // BƯỚC 2: CẬP NHẬT MẬT KHẨU MỚI
                    string query = "UPDATE TaiKhoan SET MatKhau = @NewPass WHERE TenDangNhap = @User";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@NewPass", newPassword);
                    cmd.Parameters.AddWithValue("@User", username);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        return (true, "Đổi mật khẩu thành công!");
                    }
                    else
                    {
                        return (false, "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
                    }
                }
                catch (Exception ex)
                {
                    // Trả về lỗi chi tiết cho nhà phát triển/admin
                    return (false, "Lỗi hệ thống khi đổi mật khẩu: " + ex.Message);
                }
            }
        }
    }
}