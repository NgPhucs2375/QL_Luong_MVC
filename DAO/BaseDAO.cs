using System;
using System.Configuration;
using System.Data.SqlClient;

namespace QL_Luong_MVC.DAO
{
    public class BaseDAO
    {
        // Chuỗi kết nối lấy từ Web.config
        protected string connectionString;

        public BaseDAO()
        {
            // Đảm bảo tên "TenKetNoiCuaBan" khớp với Web.config của bạn
            connectionString = ConfigurationManager.ConnectionStrings["LAPCUATWSN"].ConnectionString;
        }

        // Hàm hỗ trợ lấy Connection nhanh
        protected SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }
    }
}