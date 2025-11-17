using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Configuration; // 1. Thêm thư viện này

namespace QL_Luong_MVC.Models
{
    public class DB
    {
        // 2. Xóa chuỗi kết nối hard-code. Thay bằng biến chỉ đọc.
        public readonly string conStr;

        // Init các danh sách
        public List<NhanVien> dsNhanVien = new List<NhanVien>();
        public List<PhongBan> dsPhongBan = new List<PhongBan>();
        public List<ChucVu> dsChucVu = new List<ChucVu>();
        public List<HopDong> dsHopDong = new List<HopDong>();
        public List<BangChamCong> dsBangChamCong = new List<BangChamCong>();
        public List<PhuCap> dsPhuCap = new List<PhuCap>();
        public List<ThuongPhat> dsThuongPhat = new List<ThuongPhat>();
        public List<LuongCoban> dsLuongCoban = new List<LuongCoban>();
        public List<BangLuong> dsBangLuong = new List<BangLuong>();
        public List<TaiKhoan> dsTaiKhoan = new List<TaiKhoan>();


        // Constructor
        public DB()
        {
            // 3. Đọc chuỗi kết nối từ file Web.config (An toàn)
            try
            {
                // Thay "TenKetNoiCuaBan" bằng tên chuỗi kết nối trong Web.config
                conStr = ConfigurationManager.ConnectionStrings["TenKetNoiCuaBan"].ConnectionString;
            }
            catch (Exception ex)
            {
                throw new Exception("Lỗi: Không tìm thấy chuỗi kết nối 'TenKetNoiCuaBan' trong Web.config. " + ex.Message);
            }
            
            // 4. Luôn gọi 'Clear()' trước khi lấp đầy danh sách
            // (Đã thêm trong các hàm Lap_List bên dưới)
            Lap_ListNhanVien();
            Lap_ListPhongBan();
            Lap_ListChucVu();
            Lap_ListLuongCoBan();
            Lap_ListHopDong();
            Lap_ListPhuCap();
            Lap_ListTaiKhoan();
        }

        // 5. Gộp và sửa lỗi các hàm Lap_List...
        // Tất cả đều phải dùng 'using' và kiểm tra DBNull.Value

        public void Lap_ListNhanVien()
        {
            // Sử dụng phiên bản an toàn (từ file 2) và sửa lỗi
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM NhanVien", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsNhanVien.Clear(); // Thêm Clear

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

        public void Lap_ListPhongBan()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM PhongBan", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsPhongBan.Clear(); // Thêm Clear

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

        public void Lap_ListChucVu()
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ChucVu", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsChucVu.Clear(); // Thêm Clear

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

        public void Lap_ListLuongCoBan()
        {
            // Sửa lại hàm từ file 1 cho an toàn
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("Select * From LuongCoban", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsLuongCoban.Clear(); // Thêm Clear

                foreach (DataRow dr in dt.Rows)
                {
                    dsLuongCoban.Add(new LuongCoban
                    {
                        IDLuongCoBan = dr["MaLCB"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaLCB"]),
                        IDChucVu_LuongCB = dr["MaCV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaCV"]),
                        MucLuong = dr["MucLuong"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["MucLuong"])
                    });
                }
            }
        }

        public void Lap_ListHopDong()
        {
            // Sửa lại hàm từ file 1 cho an toàn
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM HopDong", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsHopDong.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsHopDong.Add(new HopDong
                    {
                        IDHopDong = dr["MaHD"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaHD"]),
                        IDNhanVIen_HopDong = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]),
                        DayToStart = dr["NgayBatDau"] == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(dr["NgayBatDau"]),
                        DayToEnd = dr["NgayKetThuc"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["NgayKetThuc"]),
                        Loai_HopDong = dr["LoaiHD"]?.ToString() ?? "",
                        LuongCoBan_HopDong = dr["LuongCoBan"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["LuongCoBan"]),
                        Note_HopDong = dr["GhiChu"]?.ToString() ?? ""
                    });
                }
            }
        }

        public void Lap_ListPhuCap()
        {
            // Sửa lại hàm từ file 1 cho an toàn
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM PhuCap", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dsPhuCap.Clear();

                foreach (DataRow dr in dt.Rows)
                {
                    dsPhuCap.Add(new PhuCap
                    {
                        IDPhuCap = dr["MaPC"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaPC"]),
                        IDNhanVien_PhuCap = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]),
                        Loai_PhuCap = dr["LoaiPhuCap"]?.ToString() ?? "",
                        SoTien_PhuCap = dr["SoTien"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["SoTien"])
                    });
                }
            }
        }

        public void Lap_ListTaiKhoan()
        {
            // Dùng phiên bản an toàn và sửa 'strcon' -> 'conStr'
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
                        IDNhanVien_TaiKhoan = dr["MaNV"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MaNV"]),
                        Quyen_TaiKhoan = dr["Quyen"]?.ToString() ?? "User"
                    });
                }
            }
        }

        // 6. Gộp các hàm Logic/CRUD (Sửa 'strcon' -> 'conStr')

        // Hàm thêm Hợp đồng
        public bool ThemHopDong(HopDong hd)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conStr)) // Sửa
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_ThemHopDong", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaNV", hd.IDNhanVIen_HopDong);
                    cmd.Parameters.AddWithValue("@NgayBatDau", hd.DayToStart);
                    cmd.Parameters.AddWithValue("@NgayKetThuc", (object)hd.DayToEnd ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@LoaiHD", hd.Loai_HopDong);
                    cmd.Parameters.AddWithValue("@Luongcoban", hd.LuongCoBan_HopDong);
                    cmd.Parameters.AddWithValue("@Ghichu", hd.Note_HopDong ?? (object)DBNull.Value);

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Lỗi khi thêm hợp đồng: " + ex.Message);
            }
        }


        // Hàm Thêm phụ cấp (Giữ từ file 1)
        public bool ThemPhuCap(PhuCap pc)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conStr)) // Sửa
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_ThemPhuCap", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaNV", pc.IDNhanVien_PhuCap);
                    cmd.Parameters.AddWithValue("@LoaiPhuCap", pc.Loai_PhuCap);
                    cmd.Parameters.AddWithValue("@SoTien", pc.SoTien_PhuCap);

                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi thêm phụ cấp: " + ex.Message);
                return false;
            }
        }


        // Hàm tính tổng phụ cấp của nhân viên (Giữ từ file 1)
        public decimal TongPhuCapNhanVien(int maNV)
        {
            decimal tong = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(conStr)) // Sửa
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT dbo.fn_TongPhuCap_NV(@MaNV)", con);
                    cmd.Parameters.AddWithValue("@MaNV", maNV);

                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        tong = Convert.ToDecimal(result);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi tính tổng phụ cấp: " + ex.Message);
            }
            return tong;
        }

        // 7. Thêm Class LoginResult (Lấy từ file 2)
        public class LoginResult
        {
            public bool Success { get; set; }
            public string Role { get; set; }
            public int? MaNV { get; set; }
            public string Message { get; set; }
        }

        // 8. Gộp các hàm bị trùng (Chỉ giữ 1 bản và sửa 'strcon' -> 'conStr')
        
        // HÀM KIỂM TRA ĐĂNG NHẬP
        public LoginResult CheckLogin(string username, string password)
        {
            using (SqlConnection con = new SqlConnection(conStr)) // Sửa
            {
                try
                {
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
        
        // HÀM TẠO TÀI KHOẢN
        public (bool Success, string Message) RegisterNhanVien(string TenDangNhap, string MatKhau, int MaNV)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
                {
                    conn.Open();
                    // ... (code bên trong giữ nguyên) ...
                    using (var checkNV = new SqlCommand("SELECT COUNT(1) FROM NhanVien WHERE MaNV = @MaNV", conn))
                    {
                        checkNV.Parameters.Add("@MaNV", SqlDbType.Int).Value = MaNV;
                        int existNV = Convert.ToInt32(checkNV.ExecuteScalar());
                        if (existNV == 0)
                            return (false, "❌ Mã nhân viên không tồn tại trong hệ thống.");
                    }
                    using (var checkUser = new SqlCommand("SELECT COUNT(1) FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap", conn))
                    {
                        checkUser.Parameters.Add("@TenDangNhap", SqlDbType.NVarChar, 256).Value = TenDangNhap;
                        int existUser = Convert.ToInt32(checkUser.ExecuteScalar());
                        if (existUser > 0)
                            return (false, "⚠️ Tên đăng nhập đã tồn tại.");
                    }
                    using (var cmd = new SqlCommand(
                        "INSERT INTO TaiKhoan (TenDangNhap, MatKhau, MaNV, Quyen) VALUES (@TenDangNhap, @MatKhau, @MaNV, N'User')",
                        conn))
                    {
                        cmd.Parameters.Add("@TenDangNhap", SqlDbType.NVarChar, 256).Value = TenDangNhap;
                        cmd.Parameters.Add("@MatKhau", SqlDbType.NVarChar, 256).Value = MatKhau; // ⚠️ Cảnh báo: Nên hash mật khẩu!
                        cmd.Parameters.Add("@MaNV", SqlDbType.Int).Value = MaNV;
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            return (true, "🎉 Đăng ký thành công!");
                        else
                            return (false, "⚠️ Không thể thêm tài khoản vào cơ sở dữ liệu (rows = 0).");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                return (false, "Lỗi SQL: " + sqlEx.Message);
            }
            catch (Exception ex)
            {
                return (false, "Lỗi khi đăng ký: " + ex.Message);
            }
        }
        
        // Thêm nhân viên
        public (bool Success, string Message) ThemNhanVien(NhanVien nv)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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
        
        // Lấy nhân viên theo MaNV
        public NhanVien LayNhanVienTheoID(int id)
        {
            return dsNhanVien.FirstOrDefault(nv => nv.IDNhanVien == id);
        }
        
        //  Xóa nhân viên
        public (bool Success, string Message) XoaNhanVien(int maNV)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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
        
        // Lấy phòng ban theo ID
        public PhongBan LayPhongBanTheoID(int id)
        {
            return dsPhongBan.FirstOrDefault(pb => pb.IDPhongBan == id);
        }
        
        // Thêm phòng ban
        public (bool Success, string Message) ThemPhongBan(PhongBan pb)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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
                using (SqlConnection conn = new SqlConnection(conStr)) // Sửa
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