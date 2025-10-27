using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QL_Luong_MVC.Models
{
    public class LoginResult
    {
        public bool Success { get; set; }
        public string Role { get; set; }
        public int? MaNV { get; set; }
        public string Message { get; set; }

    }
}