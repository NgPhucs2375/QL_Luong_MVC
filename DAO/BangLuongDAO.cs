using QL_Luong_MVC.Models;
using QL_Luong_MVC.ViewModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    /// <summary>
    /// DAO (Data Access Object) cho bảng BangLuong
    /// Chức năng: Quản lý bảng lương và báo cáo (UC13, UC20)
    /// </summary>
    public class BangLuongDAO : BaseDAO
    {
        // ==================================================================================
        // UC20: XEM BẢNG LƯƠNG - LẤY DANH SÁCH
        // ==================================================================================

        /// <summary>
        /// [UC20] Lấy toàn bộ bảng lương
        /// </summary>
        /// <returns>Danh sách tất cả bản ghi bảng lương</returns>
        public List<BangLuong> GetAll()
        {
            List<BangLuong> danhSach_BangLuong = new List<BangLuong>();

            using (SqlConnection conn = GetConnection())
            {
                // Lấy tất cả bảng lương, sắp xếp theo năm và tháng giảm dần
                string query = "SELECT * FROM BangLuong ORDER BY Nam DESC, Thang DESC";
                SqlCommand cmd = new SqlCommand(query, conn);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSach_BangLuong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy danh sách bảng lương: " + ex.Message);
                }
            }

            return danhSach_BangLuong;
        }

        /// <summary>
        /// [UC20] Lấy bảng lương theo tháng/năm
        /// </summary>
        /// <param name="Thang_BangLuong">Tháng cần lấy (1-12)</param>
        /// <param name="Nam_BangLuong">Năm cần lấy (VD: 2025)</param>
        /// <returns>Danh sách bảng lương trong tháng</returns>
        public List<BangLuong> GetByThang(int Thang_BangLuong, int Nam_BangLuong)
        {
            List<BangLuong> danhSach_BangLuong = new List<BangLuong>();

            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM BangLuong WHERE Thang = @Thang AND Nam = @Nam";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Thang", Thang_BangLuong);
                cmd.Parameters.AddWithValue("@Nam", Nam_BangLuong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSach_BangLuong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy bảng lương theo tháng: " + ex.Message);
                }
            }

            return danhSach_BangLuong;
        }

        /// <summary>
        /// [UC20] Lấy lịch sử lương của 1 nhân viên
        /// </summary>
        /// <param name="MaNhanVien_BangLuong">Mã nhân viên cần xem lịch sử</param>
        /// <returns>Danh sách lương của nhân viên, sắp xếp theo thời gian mới nhất</returns>
        public List<BangLuong> GetByNhanVien(int MaNhanVien_BangLuong)
        {
            List<BangLuong> danhSach_BangLuong = new List<BangLuong>();

            using (SqlConnection conn = GetConnection())
            {
                string query = @"SELECT * FROM BangLuong 
                                WHERE MaNV = @MaNV 
                                ORDER BY Nam DESC, Thang DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", MaNhanVien_BangLuong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSach_BangLuong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy lịch sử lương nhân viên: " + ex.Message);
                }
            }

            return danhSach_BangLuong;
        }

        // ==================================================================================
        // UC13: TÍNH BẢNG LƯƠNG THEO THÁNG
        // ==================================================================================

        /// <summary>
        /// [UC13] Gọi Stored Procedure sp_TinhBangLuong_Thang để tính lương
        /// SP sẽ tự động:
        /// - Xóa dữ liệu lương cũ (nếu đã tính trước đó)
        /// - Tính lại lương mới dựa trên: Lương cơ bản + Phụ cấp + Thưởng/Phạt + Giờ tăng ca
        /// </summary>
        /// <param name="Thang_BangLuong">Tháng cần tính lương (1-12)</param>
        /// <param name="Nam_BangLuong">Năm cần tính lương (VD: 2025)</param>
        /// <returns>Tuple (Success, Message)</returns>
        public (bool Success, string Message) TinhBangLuongThang(int Thang_BangLuong, int Nam_BangLuong)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Gọi Stored Procedure
                SqlCommand cmd = new SqlCommand("sp_TinhBangLuong_Thang", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                // Thêm tham số cho SP
                cmd.Parameters.AddWithValue("@Thang_BangLuong", Thang_BangLuong);
                cmd.Parameters.AddWithValue("@Nam_BangLuong", Nam_BangLuong);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();

                    // Đếm số nhân viên đã được tính lương
                    int soNhanVien_DaTinhLuong = DemSoNhanVienDaTinhLuong(Thang_BangLuong, Nam_BangLuong);

                    return (true, $"Tính lương thành công cho {soNhanVien_DaTinhLuong} nhân viên (Tháng {Thang_BangLuong}/{Nam_BangLuong})");
                }
                catch (SqlException ex)
                {
                    return (false, "Lỗi SQL khi tính lương: " + ex.Message);
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi hệ thống: " + ex.Message);
                }
            }
        }

        /// <summary>
        /// Helper method: Đếm số nhân viên đã được tính lương trong tháng
        /// </summary>
        private int DemSoNhanVienDaTinhLuong(int Thang_BangLuong, int Nam_BangLuong)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT COUNT(*) FROM BangLuong WHERE Thang = @Thang AND Nam = @Nam";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Thang", Thang_BangLuong);
                cmd.Parameters.AddWithValue("@Nam", Nam_BangLuong);

                try
                {
                    conn.Open();
                    return (int)cmd.ExecuteScalar();
                }
                catch
                {
                    return 0;
                }
            }
        }

        // ==================================================================================
        // UC20: BÁO CÁO LƯƠNG TỔNG HỢP (JOIN VỚI CÁC BẢNG LIÊN QUAN)
        // ==================================================================================

        /// <summary>
        /// [UC20] Lấy báo cáo lương tổng hợp với thông tin đầy đủ
        /// JOIN với bảng NhanVien, ChucVu, PhongBan để hiển thị đầy đủ thông tin
        /// </summary>
        /// <param name="Thang_BangLuong">Tháng cần xem báo cáo (1-12)</param>
        /// <param name="Nam_BangLuong">Năm cần xem báo cáo (VD: 2025)</param>
        /// <returns>Danh sách BaoCaoLuongViewModel với thông tin chi tiết</returns>
        public List<BaoCaoLuongViewModel> GetBaoCaoLuongThang(int Thang_BangLuong, int Nam_BangLuong)
        {
            List<BaoCaoLuongViewModel> danhSachBaoCao = new List<BaoCaoLuongViewModel>();

            using (SqlConnection conn = GetConnection())
            {
                // Truy vấn JOIN để lấy thông tin đầy đủ
                string query = @"
                    SELECT 
                        bl.MaNV,
                        nv.HoTen,
                        cv.TenCV,
                        pb.TenPB,
                        bl.Thang,
                        bl.Nam,
                        bl.LuongCoBan,
                        bl.TongPhuCap,
                        bl.TongThuongPhat,
                        bl.TongGioTangCa,
                        bl.LuongThucNhan
                    FROM BangLuong bl
                    INNER JOIN NhanVien nv ON bl.MaNV = nv.MaNV
                    LEFT JOIN ChucVu cv ON nv.MaCV = cv.MaCV
                    LEFT JOIN PhongBan pb ON nv.MaPB = pb.MaPB
                    WHERE bl.Thang = @Thang AND bl.Nam = @Nam
                    ORDER BY nv.HoTen ASC";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Thang", Thang_BangLuong);
                cmd.Parameters.AddWithValue("@Nam", Nam_BangLuong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSachBaoCao.Add(MapDataToBaoCaoViewModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy báo cáo lương: " + ex.Message);
                }
            }

            return danhSachBaoCao;
        }

        // ==================================================================================
        // HELPER METHODS: CHUYỂN ĐỔI DỮ LIỆU
        // ==================================================================================

        /// <summary>
        /// Helper method: Chuyển đổi SqlDataReader thành object BangLuong
        /// </summary>
        /// <param name="reader">SqlDataReader chứa dữ liệu từ database</param>
        /// <returns>Object BangLuong</returns>
        private BangLuong MapDataToModel(SqlDataReader reader)
        {
            return new BangLuong
            {
                // Map từ cột database sang thuộc tính Model
                IDBangLuong = Convert.ToInt32(reader["MaBangLuong"]),
                IDNhanVien_BangLuong = Convert.ToInt32(reader["MaNV"]),
                Month = Convert.ToInt32(reader["Thang"]),
                Nam = Convert.ToInt32(reader["Nam"]),
                LuongCoBan_BangLuong = reader["LuongCoBan"] != DBNull.Value ? Convert.ToDecimal(reader["LuongCoBan"]) : 0,
                TongPhuCap = reader["TongPhuCap"] != DBNull.Value ? Convert.ToDecimal(reader["TongPhuCap"]) : 0,
                TongThuongPhat = reader["TongThuongPhat"] != DBNull.Value ? Convert.ToDecimal(reader["TongThuongPhat"]) : 0,
                TongGioTangCa = reader["TongGioTangCa"] != DBNull.Value ? Convert.ToDecimal(reader["TongGioTangCa"]) : 0,
                LuongThucNhan_BangLuong = reader["LuongThucNhan"] != DBNull.Value ? Convert.ToDecimal(reader["LuongThucNhan"]) : 0
            };
        }

        /// <summary>
        /// Helper method: Chuyển đổi SqlDataReader thành BaoCaoLuongViewModel
        /// Sử dụng cho báo cáo tổng hợp (UC20)
        /// </summary>
        /// <param name="reader">SqlDataReader chứa dữ liệu JOIN từ nhiều bảng</param>
        /// <returns>Object BaoCaoLuongViewModel</returns>
        private BaoCaoLuongViewModel MapDataToBaoCaoViewModel(SqlDataReader reader)
        {
            return new BaoCaoLuongViewModel
            {
                // Thông tin nhân viên
                MaNhanVien_BaoCao = Convert.ToInt32(reader["MaNV"]),
                HoTenNhanVien_BaoCao = reader["HoTen"].ToString(),
                TenChucVu_BaoCao = reader["TenCV"] != DBNull.Value ? reader["TenCV"].ToString() : "Chưa có",
                TenPhongBan_BaoCao = reader["TenPB"] != DBNull.Value ? reader["TenPB"].ToString() : "Chưa có",

                // Thông tin lương
                Thang_BaoCao = Convert.ToInt32(reader["Thang"]),
                Nam_BaoCao = Convert.ToInt32(reader["Nam"]),
                LuongCoBan_BaoCao = reader["LuongCoBan"] != DBNull.Value ? Convert.ToDecimal(reader["LuongCoBan"]) : 0,
                TongPhuCap_BaoCao = reader["TongPhuCap"] != DBNull.Value ? Convert.ToDecimal(reader["TongPhuCap"]) : 0,
                TongThuongPhat_BaoCao = reader["TongThuongPhat"] != DBNull.Value ? Convert.ToDecimal(reader["TongThuongPhat"]) : 0,
                TongGioTangCa_BaoCao = reader["TongGioTangCa"] != DBNull.Value ? Convert.ToDecimal(reader["TongGioTangCa"]) : 0,
                LuongThucNhan_BaoCao = reader["LuongThucNhan"] != DBNull.Value ? Convert.ToDecimal(reader["LuongThucNhan"]) : 0
            };
        }
        public List<TongKetThiDuaVM> GetTongKetNam(int nam)
        {
            var list = new List<TongKetThiDuaVM>();
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_Cursor_XepLoaiThiDua_View", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Nam", nam);
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new TongKetThiDuaVM
                        {
                            MaNV = Convert.ToInt32(reader["MaNV"]),
                            HoTen = reader["HoTen"].ToString(),
                            LuongHienTai = Convert.ToDecimal(reader["LuongHienTai"]),
                            SoLanPhat = Convert.ToInt32(reader["SoLanPhat"]),
                            XepLoai = reader["XepLoai"].ToString(),
                            ThuongTet = Convert.ToDecimal(reader["ThuongTet"])
                        });
                    }
                }
                catch { }
            }
            return list;
        }

        // 2. Chốt thưởng (Insert vào DB)
        public (bool Success, string Message) ChotThuongTet(int nam)
        {
            using (SqlConnection conn = GetConnection())
            {
                SqlCommand cmd = new SqlCommand("sp_Cursor_ChotThuongTet", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Nam", nam);
                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Đã chốt thưởng và cập nhật vào hệ thống thành công!");
                }
                catch (SqlException ex) { return (false, "Lỗi: " + ex.Message); }
            }
        }
    }
}
