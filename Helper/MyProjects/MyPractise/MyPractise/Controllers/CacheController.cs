#region namespaces

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;

#endregion

namespace MyPractise.Controllers
{
    public class CacheController : Controller
    {
        //Suppose you want to cache the logged in use information then you should cached the data on client browser since this data is specific to a user. If you will cached this data on the server, all the user will see the same information that is wrong.
        //You should cache the data on the server which is common to all the users and is sensitive.
        //Location = OutputCacheLocation.Server

        //todo: проверить скорость загрузки через Network in the browser
        //повключать и поотключать  <system.webServer>

        //Location = OutputCacheLocation.Any по дефолту
        [OutputCache(Duration = 60, VaryByParam = "none", NoStore = true)]
        public ActionResult Index()
        {
            return View();
        }

        // дает 404 ошибку на клиенте
        //[OutputCache(Duration = 20, VaryByParam = "none", Location = OutputCacheLocation.Server)]
        // [OutputCache(Duration = 20, VaryByParam = "none", Location = OutputCacheLocation.Client)]
        // [OutputCache(Duration = 20, VaryByParam = "none")]

        [OutputCache(Duration = 20, VaryByParam = "ID!!")]
        public ActionResult Index1()
        {
            //var query = from 
            //            where prod.ProductId == ID!!
            //соответсвует в роутах
            return View();
        }
    }
}
