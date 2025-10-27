using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class DB
    {
        //Link DB
        static string strcon = "Data Source = MSI; database = QL_LuongNV; User ID = sa;Password = 123456";
        SqlConnection con = new SqlConnection(strcon);

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
            Lap_ListNhanVien();
            Lap_ListPhongBan();
            Lap_ListChucVu();
            Lap_ListLuongCoBan();
            Lap_ListHopDong();
            Lap_ListPhuCap();
            Lap_ListTaiKhoan();
        }

        // Hàm 
        public void Lap_ListNhanVien()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From NhanVien", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new NhanVien();
                t.IDNhanVien = int.Parse(dr["MaNV"].ToString());
                t.FullNameNhanVien = dr["HoTen"].ToString();
                t.DayOfBirth_NhanVien = DateTime.Parse(dr["NgaySinh"].ToString());
                t.Sex_NhanVien = dr["GioiTinh"].ToString();
                t.Address_NhanVien = dr["DiaChi"].ToString();
                t.SDT_NhanVien = dr["DienThoai"].ToString();
                t.Email_NhanVien = dr["Email"].ToString();
                t.State_NhanVien = dr["TrangThai"].ToString();
                t.IDCV_NhanVien= int.Parse(dr["MaCV"].ToString());
                t.IDPB_NhanVien = int.Parse(dr["MaPB"].ToString());
                dsNhanVien.Add(t);
            }
        }

        public void Lap_ListPhongBan()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From PhongBan", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new PhongBan();

                t.IDPhongBan = int.Parse(dr["MaPB"].ToString());
                t.NamePhongBan = dr["TenPB"].ToString();
                t.DateOf_Establishment = DateTime.Parse(dr["NgayThanhLap"].ToString());
                dsPhongBan.Add(t);
            }
        }

        public void Lap_ListChucVu()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From ChucVu", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new ChucVu();

                t.IDChucVu = int.Parse(dr["MaCV"].ToString());
                t.NameChucVu = dr["TenCV"].ToString();
                t.HeSoLuong_ChucVu = decimal.Parse(dr["HeSoLuong"].ToString());
                dsChucVu.Add(t);
            }
        }

        public void Lap_ListLuongCoBan()
        {
            SqlDataAdapter da = new SqlDataAdapter("Select * From LuongCoban", con);
            DataTable datatable = new DataTable();
            da.Fill(datatable);
            foreach (DataRow dr in datatable.Rows)
            {
                var t = new LuongCoban();

                t.IDLuongCoBan= int.Parse(dr["MaLCB"].ToString());
                t.IDChucVu_LuongCB = int.Parse(dr["MaCV"].ToString());
                t.MucLuong = decimal.Parse(dr["MucLuong"].ToString());
                dsLuongCoban.Add(t);
            }
        }

        public void Lap_ListHopDong()
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM HopDong", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dsHopDong.Clear();
            foreach (DataRow dr in dt.Rows)
            {
                var h = new HopDong();
                h.IDHopDong = int.Parse(dr["MaHD"].ToString());
                h.IDNhanVIen_HopDong = int.Parse(dr["MaNV"].ToString());
                h.DayToStart = DateTime.Parse(dr["NgayBatDau"].ToString());
                h.DayToEnd = dr["NgayKetThuc"] == DBNull.Value ? (DateTime?)null : DateTime.Parse(dr["NgayKetThuc"].ToString());
                h.Loai_HopDong = dr["LoaiHD"].ToString();
                h.LuongCoBan_HopDong = decimal.Parse(dr["LuongCoBan"].ToString());
                h.Note_HopDong = dr["GhiChu"].ToString();
                dsHopDong.Add(h);
            }
        }

        public void Lap_ListPhuCap()
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM PhuCap", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dsPhuCap.Clear();
            foreach (DataRow dr in dt.Rows)
            {
                var p = new PhuCap();
                p.IDPhuCap = int.Parse(dr["MaPC"].ToString());
                p.IDNhanVien_PhuCap = int.Parse(dr["MaNV"].ToString());
                p.Loai_PhuCap = dr["LoaiPhuCap"].ToString();
                p.SoTien_PhuCap = decimal.Parse(dr["SoTien"].ToString());
                dsPhuCap.Add(p);
            }
        }

        public void Lap_ListTaiKhoan()
        {
            using (SqlConnection con = new SqlConnection(strcon))
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

        // Hàm thêm Hợp đồng
        // =========================
        // UC5 - Thêm hợp đồng mới
        // =========================
        public bool ThemHopDong(HopDong hd)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_ThemHopDong", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaNV", hd.IDNhanVIen_HopDong);
                    cmd.Parameters.AddWithValue("@NgayBatDau", hd.DayToStart);
                    cmd.Parameters.AddWithValue("@NgayKetThuc",(object)hd.DayToEnd ?? DBNull.Value);
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


        // Hàm Thêm phụ cấp 
        // =========================
        // UC9 - Thêm phụ cấp mới
        // =========================
        public bool ThemPhuCap(PhuCap pc)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
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


        // Hàm tính tổng phụ cấp của nhân viên
        // =========================
        // UC10 - Tính tổng phụ cấp nhân viên
        // =========================
        public decimal TongPhuCapNhanVien(int maNV)
        {
            decimal tong = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
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

        //========================//
        //=====CLASS KẾT QUẢ ĐĂNG NHẬP///
        public LoginResult CheckLogin(string username, string password)
        {
            using (SqlConnection con = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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
        // Thêm nhân viên
        public (bool Success, string Message) ThemNhanVien(NhanVien nv)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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
                using (SqlConnection conn = new SqlConnection(strcon))
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