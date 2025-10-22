using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace QL_Luong_MVC.Models
{
    public class DB
    {
        // ======= CHUỖI KẾT NỐI =======
        private static string strcon =
            "Data Source=DESKTOP-5EMC8PJ\\MSSQLSERVER02; Initial Catalog=QL_LuongNV; Integrated Security=True; TrustServerCertificate=True;";
        SqlConnection con = new SqlConnection(strcon);
        public string conStr = strcon;
        public void OpenConnection()
        {
            if (con.State == System.Data.ConnectionState.Closed)
                con.Open();
        }

        // ✅ Hàm hỗ trợ đóng kết nối an toàn
        public void CloseConnection()
        {
            if (con.State == System.Data.ConnectionState.Open)
                con.Close();
        }

        // ======= DANH SÁCH DỮ LIỆU =======
        public List<NhanVien> dsNhanVien = new List<NhanVien>();
        public List<PhongBan> dsPhongBan = new List<PhongBan>();
        public List<ChucVu> dsChucVu = new List<ChucVu>();
        public List<TaiKhoan> dsTaiKhoan = new List<TaiKhoan>();

        // ======= CONSTRUCTOR =======
        public DB()
        {
            Lap_ListNhanVien();
            Lap_ListPhongBan();
            Lap_ListChucVu();
            Lap_ListTaiKhoan();
        }

        // ======= TẢI DANH SÁCH NHÂN VIÊN =======
        public void Lap_ListNhanVien()
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

        // ======= TẢI DANH SÁCH PHÒNG BAN =======
        public void Lap_ListPhongBan()
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

        // ======= TẢI DANH SÁCH CHỨC VỤ =======
        public void Lap_ListChucVu()
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

        // ======= TẢI DANH SÁCH TÀI KHOẢN =======
        public void Lap_ListTaiKhoan()
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

        // ======= HÀM TẠO TÀI KHOẢN =======

        public (bool Success, string Message) RegisterNhanVien(string TenDangNhap, string MatKhau, int MaNV)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();

                    // ✅ Log ra connection string để kiểm tra đang trỏ đúng DB chưa
                    System.Diagnostics.Debug.WriteLine("👉 Kết nối tới DB: " + conn.Database);

                    // ✅ 1. Kiểm tra mã NV tồn tại
                    SqlCommand checkNV = new SqlCommand("SELECT COUNT(*) FROM NhanVien WHERE MaNV = @MaNV", conn);
                    checkNV.Parameters.AddWithValue("@MaNV", MaNV);
                    int existNV = (int)checkNV.ExecuteScalar();

                    if (existNV == 0)
                    {
                        return (false, "❌ Mã nhân viên không tồn tại trong hệ thống.");
                    }

                    // ✅ 2. Kiểm tra trùng tên đăng nhập
                    SqlCommand checkUser = new SqlCommand("SELECT COUNT(*) FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap", conn);
                    checkUser.Parameters.AddWithValue("@TenDangNhap", TenDangNhap);
                    int existUser = (int)checkUser.ExecuteScalar();

                    if (existUser > 0)
                    {
                        return (false, "⚠️ Tên đăng nhập đã tồn tại.");
                    }

                    // ✅ 3. Thêm tài khoản mới
                    SqlCommand cmd = new SqlCommand(
                        "INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, Quyen) VALUES (@TenDangNhap, @MatKhau, @MaNV, N'User')",
                        conn
                    );
                    cmd.Parameters.AddWithValue("@TenDangNhap", TenDangNhap);
                    cmd.Parameters.AddWithValue("@MatKhau", MatKhau);
                    cmd.Parameters.AddWithValue("@MaNV", MaNV);

                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                        return (true, "🎉 Đăng ký thành công!");
                    else
                        return (false, "⚠️ Không thể thêm tài khoản vào cơ sở dữ liệu (rows = 0).");
                }
            }
            catch (SqlException sqlEx)
            {
                // ✅ Log lỗi chi tiết của SQL Server
                System.Diagnostics.Debug.WriteLine("❌ SQL Error: " + sqlEx.Message);
                return (false, "Lỗi SQL: " + sqlEx.Message);
            }
            catch (Exception ex)
            {
                // ✅ Log lỗi chung
                System.Diagnostics.Debug.WriteLine("⚠️ Lỗi hệ thống: " + ex.Message);
                return (false, "Lỗi khi đăng ký: " + ex.Message);
            }
        }

    }
}

