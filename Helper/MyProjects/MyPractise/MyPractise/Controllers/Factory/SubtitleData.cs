#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

#endregion

namespace MyPractise.Controllers.Factory
{
    public class SubtitleData : BaseAutoActionFilter
    {
        //private readonly ISubtitleBuilder _builder;

       /* public SubtitleData(ISubtitleBuilder builder)
        {
            _builder = builder;
        }*/

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            filterContext.Controller.ViewData["subtitle"] = "";
        }
    }
}