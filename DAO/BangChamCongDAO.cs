using QL_Luong_MVC.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    /// <summary>
    /// DAO (Data Access Object) cho bảng BangChamCong
    /// Chức năng: Quản lý chấm công nhân viên (UC6, UC7, UC8)
    /// </summary>
    public class BangChamCongDAO : BaseDAO
    {
        // ==================================================================================
        // UC6: CHẤM CÔNG NHÂN VIÊN - LẤY DANH SÁCH
        // ==================================================================================

        /// <summary>
        /// [UC6] Lấy toàn bộ danh sách chấm công
        /// </summary>
        /// <returns>Danh sách tất cả bản ghi chấm công</returns>
        public List<BangChamCong> GetAll()
        {
            // Khởi tạo danh sách kết quả trả về
            List<BangChamCong> danhSach_BangChamCong = new List<BangChamCong>();

            // Sử dụng using để tự động đóng kết nối sau khi xong
            using (SqlConnection conn = GetConnection())
            {
                // Câu truy vấn SQL lấy tất cả bản ghi
                string query = "SELECT * FROM BangChamCong ORDER BY Ngay DESC";
                SqlCommand cmd = new SqlCommand(query, conn);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    // Đọc từng dòng dữ liệu và chuyển thành object
                    while (reader.Read())
                    {
                        danhSach_BangChamCong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy danh sách chấm công: " + ex.Message);
                }
            }

            return danhSach_BangChamCong;
        }

        /// <summary>
        /// [UC6] Lấy danh sách chấm công theo nhân viên
        /// </summary>
        /// <param name="MaNhanVien_BangChamCong">Mã nhân viên cần lấy dữ liệu chấm công</param>
        /// <returns>Danh sách chấm công của nhân viên</returns>
        public List<BangChamCong> GetByNhanVien(int MaNhanVien_BangChamCong)
        {
            List<BangChamCong> danhSach_BangChamCong = new List<BangChamCong>();

            using (SqlConnection conn = GetConnection())
            {
                // Truy vấn lọc theo MaNV, sắp xếp theo ngày giảm dần
                string query = "SELECT * FROM BangChamCong WHERE MaNV = @MaNV ORDER BY Ngay DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", MaNhanVien_BangChamCong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSach_BangChamCong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy chấm công theo nhân viên: " + ex.Message);
                }
            }

            return danhSach_BangChamCong;
        }

        /// <summary>
        /// [UC6] Lấy danh sách chấm công theo tháng/năm
        /// </summary>
        /// <param name="Thang_BangChamCong">Tháng cần lấy (1-12)</param>
        /// <param name="Nam_BangChamCong">Năm cần lấy (VD: 2025)</param>
        /// <returns>Danh sách chấm công trong tháng</returns>
        public List<BangChamCong> GetByThang(int Thang_BangChamCong, int Nam_BangChamCong)
        {
            List<BangChamCong> danhSach_BangChamCong = new List<BangChamCong>();

            using (SqlConnection conn = GetConnection())
            {
                // Sử dụng hàm MONTH() và YEAR() để lọc theo tháng/năm
                string query = @"SELECT * FROM BangChamCong 
                                WHERE MONTH(Ngay) = @Thang AND YEAR(Ngay) = @Nam 
                                ORDER BY Ngay DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Thang", Thang_BangChamCong);
                cmd.Parameters.AddWithValue("@Nam", Nam_BangChamCong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        danhSach_BangChamCong.Add(MapDataToModel(reader));
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy chấm công theo tháng: " + ex.Message);
                }
            }

            return danhSach_BangChamCong;
        }

        /// <summary>
        /// [UC6] Lấy 1 bản ghi chấm công theo ID
        /// </summary>
        /// <param name="MaChamCong_BangChamCong">Mã chấm công cần lấy</param>
        /// <returns>Bản ghi chấm công hoặc null nếu không tìm thấy</returns>
        public BangChamCong GetById(int MaChamCong_BangChamCong)
        {
            BangChamCong chamCong = null;

            using (SqlConnection conn = GetConnection())
            {
                string query = "SELECT * FROM BangChamCong WHERE MaCC = @MaCC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaCC", MaChamCong_BangChamCong);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        chamCong = MapDataToModel(reader);
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi lấy chấm công theo ID: " + ex.Message);
                }
            }

            return chamCong;
        }

        // ==================================================================================
        // UC6 + UC7: THÊM CHẤM CÔNG (Trigger tự động kiểm tra trùng)
        // ==================================================================================

        /// <summary>
        /// [UC6] Thêm bản ghi chấm công mới
        /// [UC7] Trigger trg_PreventDuplicate_ChanCong sẽ tự động kiểm tra trùng ngày
        /// </summary>
        /// <param name="chamCong_BangChamCong">Object chứa thông tin chấm công</param>
        /// <returns>Tuple (Success, Message) - Success=true nếu thành công</returns>
        public (bool Success, string Message) Insert(BangChamCong chamCong_BangChamCong)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Câu lệnh INSERT vào bảng BangChamCong
                string query = @"INSERT INTO BangChamCong (MaNV, Ngay, NgayCong, GioTangCa) 
                                VALUES (@MaNV, @Ngay, @NgayCong, @GioTangCa)";

                SqlCommand cmd = new SqlCommand(query, conn);

                // Thêm tham số với tên biến rõ ràng
                cmd.Parameters.AddWithValue("@MaNV", chamCong_BangChamCong.IDNhanVien_ChamCong);
                cmd.Parameters.AddWithValue("@Ngay", chamCong_BangChamCong.Day_ChamCong);
                cmd.Parameters.AddWithValue("@NgayCong", chamCong_BangChamCong.DayCong_ChamCong);
                cmd.Parameters.AddWithValue("@GioTangCa", chamCong_BangChamCong.GioTangCa);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return (true, "Chấm công thành công!");
                }
                catch (SqlException ex)
                {
                    // Bắt lỗi từ Trigger UC7 (chấm công trùng ngày)
                    if (ex.Message.Contains("Chấm công trùng ngày"))
                    {
                        return (false, "Lỗi: Nhân viên này đã được chấm công trong ngày hôm nay!");
                    }
                    return (false, "Lỗi SQL: " + ex.Message);
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi hệ thống: " + ex.Message);
                }
            }
        }

        // ==================================================================================
        // UC6: CẬP NHẬT VÀ XÓA CHẤM CÔNG
        // ==================================================================================

        /// <summary>
        /// [UC6] Cập nhật thông tin chấm công
        /// </summary>
        /// <param name="chamCong_BangChamCong">Object chứa thông tin chấm công cần cập nhật</param>
        /// <returns>Tuple (Success, Message)</returns>
        public (bool Success, string Message) Update(BangChamCong chamCong_BangChamCong)
        {
            using (SqlConnection conn = GetConnection())
            {
                // Chỉ cho phép sửa NgayCong và GioTangCa, không sửa MaNV và Ngay
                string query = @"UPDATE BangChamCong 
                                SET NgayCong = @NgayCong, GioTangCa = @GioTangCa 
                                WHERE MaCC = @MaCC";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaCC", chamCong_BangChamCong.IDChamCong);
                cmd.Parameters.AddWithValue("@NgayCong", chamCong_BangChamCong.DayCong_ChamCong);
                cmd.Parameters.AddWithValue("@GioTangCa", chamCong_BangChamCong.GioTangCa);

                try
                {
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                        return (true, "Cập nhật chấm công thành công!");
                    else
                        return (false, "Không tìm thấy bản ghi chấm công.");
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }

        /// <summary>
        /// [UC6] Xóa bản ghi chấm công
        /// </summary>
        /// <param name="MaChamCong_BangChamCong">Mã chấm công cần xóa</param>
        /// <returns>Tuple (Success, Message)</returns>
        public (bool Success, string Message) Delete(int MaChamCong_BangChamCong)
        {
            using (SqlConnection conn = GetConnection())
            {
                string query = "DELETE FROM BangChamCong WHERE MaCC = @MaCC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaCC", MaChamCong_BangChamCong);

                try
                {
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                        return (true, "Xóa chấm công thành công!");
                    else
                        return (false, "Không tìm thấy bản ghi chấm công.");
                }
                catch (Exception ex)
                {
                    return (false, "Lỗi: " + ex.Message);
                }
            }
        }

        // ==================================================================================
        // UC8: TÍNH TỔNG GIỜ TĂNG CA THÁNG
        // ==================================================================================

        /// <summary>
        /// [UC8] Gọi function fn_TongGioTangCa_Thang để tính tổng giờ tăng ca
        /// </summary>
        /// <param name="MaNhanVien_BangChamCong">Mã nhân viên</param>
        /// <param name="Thang_BangLuong">Tháng cần tính (1-12)</param>
        /// <param name="Nam_BangLuong">Năm cần tính (VD: 2025)</param>
        /// <returns>Tổng giờ tăng ca (DECIMAL)</returns>
        public decimal GetTongGioTangCaThang(int MaNhanVien_BangChamCong, int Thang_BangLuong, int Nam_BangLuong)
        {
            decimal tongGio_BangChamCong = 0;

            using (SqlConnection conn = GetConnection())
            {
                // Gọi function SQL để tính tổng giờ tăng ca
                string query = "SELECT dbo.fn_TongGioTangCa_Thang(@MaNV, @Thang, @Nam)";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MaNV", MaNhanVien_BangChamCong);
                cmd.Parameters.AddWithValue("@Thang", Thang_BangLuong);
                cmd.Parameters.AddWithValue("@Nam", Nam_BangLuong);

                try
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    // Chuyển đổi kết quả sang decimal
                    if (result != null && result != DBNull.Value)
                    {
                        tongGio_BangChamCong = Convert.ToDecimal(result);
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Lỗi khi tính tổng giờ tăng ca: " + ex.Message);
                }
            }

            return tongGio_BangChamCong;
        }

        // ==================================================================================
        // HELPER METHOD: CHUYỂN ĐỔI DỮ LIỆU TỪ DATABASE SANG MODEL
        // ==================================================================================

        /// <summary>
        /// Helper method: Chuyển đổi SqlDataReader thành object BangChamCong
        /// </summary>
        /// <param name="reader">SqlDataReader chứa dữ liệu từ database</param>
        /// <returns>Object BangChamCong</returns>
        private BangChamCong MapDataToModel(SqlDataReader reader)
        {
            return new BangChamCong
            {
                // Map từ cột database sang thuộc tính Model
                // Tên biến rõ ràng: TenThuocTinh_TenBang
                IDChamCong = Convert.ToInt32(reader["MaCC"]),
                IDNhanVien_ChamCong = Convert.ToInt32(reader["MaNV"]),
                Day_ChamCong = Convert.ToDateTime(reader["Ngay"]),
                DayCong_ChamCong = Convert.ToDecimal(reader["NgayCong"]),
                GioTangCa = Convert.ToDecimal(reader["GioTangCa"])
            };
        }
    }
}
