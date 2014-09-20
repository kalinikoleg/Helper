#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http.Controllers;
using System.Web.Mvc;

#endregion

namespace MyPractise.Controllers.Factory
{
    public abstract class BaseAutoActionFilter : IAutoActionFilter
    {
        public virtual void OnActionExecuting(ActionExecutingContext filterContext)
        {
            
        }

        public virtual void OnActionExecuted(ActionExecutedContext filterContext)
        {

        }
    }
}