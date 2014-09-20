#region namespaces

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;
using MyPractise.Attributes;
using MyPractise.Controllers.Base;
using MyPractise.Entities;

#endregion

namespace MyPractise.Controllers
{
    public class AjaxController : BaseController
    {

        [OutputCache(Duration = 20, VaryByParam = "none", Location = OutputCacheLocation.Any)]
        public ActionResult Index()
        {
            return View();
        }


        //there is UI part of validate attr in Scripts/ViewModels/Ajax/index.js
        [HttpPost]
        [ValidateAntiForgeryPostAjax]
        [OutputCache(Duration = 10, VaryByParam = "none", Location = OutputCacheLocation.Client)]
        //todo: check speed for any location, переубкдиться, срабатует ли Client
        public JsonResult GetUserList(long? id)
        {
            User user = new User();

            List<User> users = new List<User>()
            {
                new User(){Id = 1, FirstName = "Oleg", LastName = "Kalinik"},
                new User(){Id = 2, FirstName = "Stas", LastName = "Ivanov"}
            };

            return Json(users);
        }

    }
}
