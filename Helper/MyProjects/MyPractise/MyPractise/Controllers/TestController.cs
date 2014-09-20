#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using MyPractise.Controllers.Base;
using MyPractise.ViewModels;

#endregion

namespace MyPractise.Controllers
{
    public class TestController : BaseController
    {

        #region Expessions
        // Expression<Func<int, int, bool>> isFactorExp = (n, d) => (d != 0) ? (n % d) == 0 : false;

        public void TestExpressions()
        {
            // Деревья выражений, не поддержует {}, блочный код
            //Expression<TDelegate>
            Expression<Func<int, int, bool>> isFactorExp = (n, d) => (d != 0) ? (n % d) == 0 : false;
            Func<int, int, bool> isFact = isFactorExp.Compile();

            bool res = isFact(10, 5);

        }

        #endregion

        public ActionResult Index()
        {
            var routeData = RouteData.Values;

            var currentController = routeData["controller"];
            var currentAction = routeData["action"];
            var optionalId = routeData["id"];

            Test model = new Test();
            return View(model);
        }


        [NonAction]
        public string GetData()
        {
            return string.Empty;
        }



    }
}
