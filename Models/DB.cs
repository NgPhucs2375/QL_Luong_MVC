using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Configuration;

namespace QL_Luong_MVC.Models
{
    public class DB
    {
        public static string strcon;
        public readonly string conStr;

        // ======= DANH SÁCH DỮ LIỆU =======
        public List<NhanVien> dsNhanVien = new List<NhanVien>();
        public List<PhongBan> dsPhongBan = new List<PhongBan>();
        public List<ChucVu> dsChucVu = new List<ChucVu>();
        public List<TaiKhoan> dsTaiKhoan = new List<TaiKhoan>();

        // ======= CONSTRUCTOR =======
        public DB()
        {
            //strcon = ConfigurationManager.ConnectionStrings["QL_Luong_MVC"]?.ConnectionString 
            //                          ?? "Data Source=DESKTOP-5EMC8PJ;Initial Catalog=QL_LuongNV;Integrated Security=True;TrustServerCertificate=True;";
            strcon = ConfigurationManager.ConnectionStrings["QL_Luong_MVC"]?.ConnectionString
                                ?? "Data Source=DESKTOP-I1S5SR8;Initial Catalog=QL_LuongNV;User ID=sa;Password=123;TrustServerCertificate=True;";

            conStr = strcon;
            Lap_ListNhanVien();
            Lap_ListPhongBan();
            Lap_ListChucVu();

        }

        // ======= TẢI DANH SÁCH NHÂN VIÊN =======
        public void Lap_ListNhanVien()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM NhanVien", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsNhanVien.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsNhanVien.Add(new NhanVien
                    {
                        IDNhanVien = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]),
                        FullNameNhanVien = dr["HoTen"]?.ToString() ?? "",
                        DayOfBirth_NhanVien = dr["NgaySinh"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(dr["NgaySinh"]),
                        Sex_NhanVien = dr["GioiTinh"]?.ToString() ?? "",
                        Address_NhanVien = dr["DiaChi"]?.ToString() ?? "",
                        SDT_NhanVien = dr["DienThoai"]?.ToString() ?? "",
                        Email_NhanVien = dr["Email"]?.ToString() ?? "",
                        State_NhanVien = dr["TrangThai"]?.ToString() ?? "",
                        IDCV_NhanVien = dr["MaCV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaCV"]),
                        IDPB_NhanVien = dr["MaPB"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaPB"])
                    });
                }
            }
        }

        // ======= TẢI DANH SÁCH PHÒNG BAN =======
        public void Lap_ListPhongBan()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM PhongBan", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsPhongBan.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsPhongBan.Add(new PhongBan
                    {
                        IDPhongBan = dr["MaPB"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaPB"]),
                        NamePhongBan = dr["TenPB"]?.ToString() ?? "",
                        DateOf_Establishment = dr["NgayThanhLap"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(dr["NgayThanhLap"])
                    });
                }
            }
        }

        // ======= TẢI DANH SÁCH CHỨC VỤ =======
        public void Lap_ListChucVu()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ChucVu", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsChucVu.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsChucVu.Add(new ChucVu
                    {
                        IDChucVu = dr["MaCV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaCV"]),
                        NameChucVu = dr["TenCV"]?.ToString() ?? "",
                        HeSoLuong_ChucVu = dr["HeSoLuong"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["HeSoLuong"])
                    });
                }
            }
        }

        // ======= TẢI DANH SÁCH TÀI KHOẢN =======
        public void Lap_ListTaiKhoan()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TaiKhoan", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsTaiKhoan.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsTaiKhoan.Add(new TaiKhoan
                    {
                        TenDangNhap = dr["TenDangNhap"]?.ToString() ?? "",
                        MatKhau = dr["MatKhau"]?.ToString() ?? "",
                        MaNV = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]),
                        Quyen = dr["Quyen"]?.ToString() ?? "User"
                    });
                }
            }
        }

        // ======= CLASS KẾT QUẢ ĐĂNG NHẬP =======
        public class LoginResult
        {
            public bool Success { get; set; }
            public string Role { get; set; }
            public int? MaNV { get; set; }
            public string Message { get; set; }
        }

        // ======= HÀM KIỂM TRA ĐĂNG NHẬP =======
        public LoginResult CheckLogin(string username, string password)
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                try
                {
                    // ✅ Nếu là admin cố định
                    if (username.ToLower() == "admin" && password == "123456")
                        return new LoginResult { Success = true, Role = "Admin", MaNV = 0 };

                    SqlCommand cmd = new SqlCommand("SELECT * FROM TaiKhoan WHERE TenDangNhap=@user AND MatKhau=@pass", con);
                    cmd.Parameters.AddWithValue("@user", username);
                    cmd.Parameters.AddWithValue("@pass", password);

                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        int manv = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]);
                        string role = dr["Quyen"]?.ToString() ?? "User";
                        con.Close();
                        return new LoginResult { Success = true, Role = role, MaNV = manv };
                    }
                    con.Close();

                    return new LoginResult { Success = false, Message = "Sai tên đăng nhập hoặc mật khẩu." };
                }
                catch (Exception ex)
                {
                    con.Close();
                    return new LoginResult { Success = false, Message = ex.Message };
                }
            }
        }

        // ======= HÀM TẠO TÀI KHOẢN =======
        public (bool Success, string Message) RegisterNhanVien(string TenDangNhap, string MatKhau, int MaNV)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    System.Diagnostics.Debug.WriteLine("👉 Kết nối tới DB: " + conn.DataSource + " | Catalog: " + conn.Database);

                    // 1) Kiểm tra MaNV tồn tại
                    using (var checkNV = new SqlCommand("SELECT COUNT(1) FROM NhanVien WHERE MaNV = @MaNV", conn))
                    {
                        checkNV.Parameters.Add("@MaNV", SqlDbType.Int).Value = MaNV;
                        int existNV = Convert.ToInt32(checkNV.ExecuteScalar());
                        System.Diagnostics.Debug.WriteLine("👉 existNV = " + existNV);
                        if (existNV == 0)
                            return (false, "❌ Mã nhân viên không tồn tại trong hệ thống.");
                    }

                    // 2) Kiểm tra TenDangNhap trùng
                    using (var checkUser = new SqlCommand("SELECT COUNT(1) FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap", conn))
                    {
                        checkUser.Parameters.Add("@TenDangNhap", SqlDbType.NVarChar, 256).Value = TenDangNhap;
                        int existUser = Convert.ToInt32(checkUser.ExecuteScalar());
                        System.Diagnostics.Debug.WriteLine("👉 existUser = " + existUser);
                        if (existUser > 0)
                            return (false, "⚠️ Tên đăng nhập đã tồn tại.");
                    }

                    // 3) Insert với tham số rõ ràng
                    using (var cmd = new SqlCommand(
                        "INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, Quyen) VALUES (@TenDangNhap, @MatKhau, @MaNV, N'User')",
                        conn))
                    {
                        cmd.Parameters.Add("@TenDangNhap", SqlDbType.NVarChar, 256).Value = TenDangNhap;
                        cmd.Parameters.Add("@MatKhau", SqlDbType.NVarChar, 256).Value = MatKhau;
                        cmd.Parameters.Add("@MaNV", SqlDbType.Int).Value = MaNV;

                        int rows = cmd.ExecuteNonQuery();
                        System.Diagnostics.Debug.WriteLine("👉 ExecuteNonQuery rows = " + rows);

                        if (rows > 0)
                            return (true, "🎉 Đăng ký thành công!");
                        else
                            return (false, "⚠️ Không thể thêm tài khoản vào cơ sở dữ liệu (rows = 0).");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                System.Diagnostics.Debug.WriteLine("❌ SQL Error: " + sqlEx.Message + " | Number: " + sqlEx.Number);
                return (false, "Lỗi SQL: " + sqlEx.Message);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("⚠️ Lỗi hệ thống: " + ex.Message);
                return (false, "Lỗi khi đăng ký: " + ex.Message);
            }
        }
        // ======================== NHÂN VIÊN: THÊM - SỬA - XÓA ========================

        // Thêm nhân viên
        public (bool Success, string Message) ThemNhanVien(NhanVien nv)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = @"INSERT INTO NhanVien (HoTen, GioiTinh, NgaySinh, DiaChi, DienThoai, Email, TrangThai, MaCV, MaPB)
                           VALUES (@HoTen, @GioiTinh, @NgaySinh, @DiaChi, @DienThoai, @Email, @TrangThai, @MaCV, @MaPB)";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@HoTen", nv.FullNameNhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@GioiTinh", nv.Sex_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@NgaySinh", nv.DayOfBirth_NhanVien == DateTime.MinValue ? (object)DBNull.Value : nv.DayOfBirth_NhanVien);
                        cmd.Parameters.AddWithValue("@DiaChi", nv.Address_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@DienThoai", nv.SDT_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Email", nv.Email_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@TrangThai", nv.State_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@MaCV", nv.IDCV_NhanVien == 0 ? (object)DBNull.Value : nv.IDCV_NhanVien);
                        cmd.Parameters.AddWithValue("@MaPB", nv.IDPB_NhanVien == 0 ? (object)DBNull.Value : nv.IDPB_NhanVien);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            return (true, "✅ Thêm nhân viên thành công!");
                        else
                            return (false, "⚠️ Không thể thêm nhân viên.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "❌ Lỗi khi thêm nhân viên: " + ex.Message);
            }
        }

        // Sửa nhân viên
        public (bool Success, string Message) SuaNhanVien(NhanVien nv)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = @"UPDATE NhanVien SET 
                               HoTen=@HoTen, GioiTinh=@GioiTinh, NgaySinh=@NgaySinh,
                               DiaChi=@DiaChi, DienThoai=@DienThoai, Email=@Email,
                               TrangThai=@TrangThai, MaCV=@MaCV, MaPB=@MaPB
                           WHERE MaNV=@MaNV";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MaNV", nv.IDNhanVien);
                        cmd.Parameters.AddWithValue("@HoTen", nv.FullNameNhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@GioiTinh", nv.Sex_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@NgaySinh", nv.DayOfBirth_NhanVien == DateTime.MinValue ? (object)DBNull.Value : nv.DayOfBirth_NhanVien);
                        cmd.Parameters.AddWithValue("@DiaChi", nv.Address_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@DienThoai", nv.SDT_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Email", nv.Email_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@TrangThai", nv.State_NhanVien ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@MaCV", nv.IDCV_NhanVien == 0 ? (object)DBNull.Value : nv.IDCV_NhanVien);
                        cmd.Parameters.AddWithValue("@MaPB", nv.IDPB_NhanVien == 0 ? (object)DBNull.Value : nv.IDPB_NhanVien);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            return (true, "✏️ Sửa thông tin thành công!");
                        else
                            return (false, "⚠️ Không tìm thấy nhân viên cần sửa.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "❌ Lỗi khi sửa nhân viên: " + ex.Message);
            }
        }
        public NhanVien LayNhanVienTheoID(int id)
        {
            return dsNhanVien.FirstOrDefault(nv => nv.IDNhanVien == id);
        }

        //  Xóa nhân viên
        public (bool Success, string Message) XoaNhanVien(int maNV)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = "DELETE FROM NhanVien WHERE MaNV = @MaNV";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MaNV", maNV);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            return (true, "🗑️ Đã xóa nhân viên thành công!");
                        else
                            return (false, "⚠️ Không tìm thấy nhân viên cần xóa.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "❌ Lỗi khi xóa nhân viên: " + ex.Message);
            }
        }
        public PhongBan LayPhongBanTheoID(int id)
        {
            return dsPhongBan.FirstOrDefault(pb => pb.IDPhongBan == id);
        }

        // Thêm phòng ban
        public (bool Success, string Message) ThemPhongBan(PhongBan pb)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = @"INSERT INTO PhongBan (TenPB, NgayThanhLap)
                           VALUES (@TenPB, @NgayThanhLap)";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@TenPB", pb.NamePhongBan ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@NgayThanhLap", pb.DateOf_Establishment == DateTime.MinValue
                                                                    ? (object)DBNull.Value
                                                                    : pb.DateOf_Establishment);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            Lap_ListPhongBan(); // cập nhật dsPhongBan
                            return (true, "Thêm phòng ban thành công!");
                        }
                        else
                            return (false, "Không thể thêm phòng ban.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "Lỗi khi thêm phòng ban: " + ex.Message);
            }
        }

        // Sửa phòng ban
        public (bool Success, string Message) SuaPhongBan(PhongBan pb)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = @"UPDATE PhongBan SET 
                               TenPB=@TenPB, NgayThanhLap=@NgayThanhLap
                           WHERE MaPB=@MaPB";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MaPB", pb.IDPhongBan);
                        cmd.Parameters.AddWithValue("@TenPB", pb.NamePhongBan ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@NgayThanhLap", pb.DateOf_Establishment == DateTime.MinValue
                                                                    ? (object)DBNull.Value
                                                                    : pb.DateOf_Establishment);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            Lap_ListPhongBan(); // cập nhật dsPhongBan
                            return (true, "Sửa thông tin phòng ban thành công!");
                        }
                        else
                            return (false, "Không tìm thấy phòng ban cần sửa.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "Lỗi khi sửa phòng ban: " + ex.Message);
            }
        }

        // Xóa phòng ban
        public (bool Success, string Message) XoaPhongBan(int id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    string sql = "DELETE FROM PhongBan WHERE MaPB=@MaPB";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MaPB", id);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            Lap_ListPhongBan(); // cập nhật dsPhongBan
                            return (true, "Đã xóa phòng ban thành công!");
                        }
                        else
                            return (false, "Không tìm thấy phòng ban cần xóa.");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "Lỗi khi xóa phòng ban: " + ex.Message);
            }
        }

    }
}

