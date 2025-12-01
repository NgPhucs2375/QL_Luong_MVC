using System;
using System.Security.Cryptography;
using System.Text;

namespace QL_Luong_MVC.DAO // Hoặc namespace Utils
{
    public static class SecurityHelper
    {
        // Hàm mã hóa SHA256 đơn giản
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                // Chuyển chuỗi mật khẩu sang byte
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));

                // Chuyển byte mảng sang chuỗi Hex
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }
    }
}