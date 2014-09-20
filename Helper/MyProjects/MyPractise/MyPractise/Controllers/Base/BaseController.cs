#region namespaces

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyPractise.Exstentions;

#endregion

namespace MyPractise.Controllers.Base
{
    public class BaseController : Controller
    {
        protected override JsonResult Json(object data, string contentType, System.Text.Encoding contentEncoding, JsonRequestBehavior behavior)
        {
            return new JsonNetResult()
            {
                Data = data,
                ContentType = contentType,
                ContentEncoding = contentEncoding,
                JsonRequestBehavior = behavior
            };
        }

        protected AutoMappedViewResult AutoMappedView<TModel>(object Model)
        {
            ViewData.Model = Model;
            return new AutoMappedViewResult(typeof(TModel))
            {
                ViewData = ViewData,
                TempData = TempData
            };
        }
    }
}
