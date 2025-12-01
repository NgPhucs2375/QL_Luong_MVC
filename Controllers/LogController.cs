using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using QL_Luong_MVC.ViewModel;
using QL_Luong_MVC.DAO;

namespace QL_Luong_MVC.Controllers
{
    [CustomAuthorize(Roles = "Admin")]
    public class LogController : Controller
    {
        private LogDAO logDao = new LogDAO();

        public ActionResult Index()
        {
            var model = new SystemLogViewModel
            {
                LogsChamCong = logDao.GetLogChamCong(),
                LogsXoaNV = logDao.GetLogXoaNV()
            };
            return View(model);
        }
    }
}