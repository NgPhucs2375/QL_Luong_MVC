// Tạo file Models/AppConst.cs
namespace QL_Luong_MVC.Models
{
    public static class RoleConst
    {
        public const string Admin = "Admin";
        public const string NhanSu = "NhanSu";
        public const string KeToan = "KeToan";
        public const string User = "User"; // Đảm bảo trong DB bảng TaiKhoan cột Quyen cũng lưu chữ "User"
    }
}