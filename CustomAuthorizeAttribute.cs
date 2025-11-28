using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace QL_Luong_MVC // Nhớ check namespace
{
    public class CustomAuthorizeAttribute : ActionFilterAttribute
    {
        public string Roles { get; set; }

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // 1. Lấy Session an toàn
            var sessionUser = filterContext.HttpContext.Session["TenDangNhap"];
            var sessionRole = filterContext.HttpContext.Session["Quyen"] as string;

            // 2. Nếu Session chết -> Đá về Login ngay lập tức
            if (sessionUser == null || string.IsNullOrEmpty(sessionRole))
            {
                filterContext.Result = new RedirectToRouteResult(
                    new RouteValueDictionary(new { controller = "Login", action = "Login" })
                );
                return;
            }

            // 3. Nếu Action yêu cầu quyền cụ thể (Roles không null)
            if (!string.IsNullOrEmpty(Roles))
            {
                bool isAuthorized = false;
                // Tách chuỗi "Admin, KeToan" thành mảng và so sánh không phân biệt hoa thường
                foreach (var role in Roles.Split(','))
                {
                    if (sessionRole.Trim().Equals(role.Trim(), System.StringComparison.OrdinalIgnoreCase))
                    {
                        isAuthorized = true;
                        break;
                    }
                }

                if (!isAuthorized)
                {
                    // 4. Xử lý khi không đủ quyền (Access Denied)
                    filterContext.Controller.TempData["Error"] = "⛔ Bạn không có quyền truy cập chức năng này!";

                    // Phân luồng trả về để tránh vòng lặp vô hạn
                    if (sessionRole.Equals("User", System.StringComparison.OrdinalIgnoreCase))
                    {
                        // User thường thì về Dashboard User
                        filterContext.Result = new RedirectResult("/Home/DashboardUser");
                    }
                    else
                    {
                        // Admin/HR/Ketoan thì về Dashboard Admin
                        filterContext.Result = new RedirectResult("/Home/Index");
                    }
                }
            }
        }
    }
}