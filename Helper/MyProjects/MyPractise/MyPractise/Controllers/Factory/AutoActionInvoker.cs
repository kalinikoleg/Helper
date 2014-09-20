using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace MyPractise.Controllers.Factory
{
    public class AutoActionInvoker : ControllerActionInvoker
    {
        private readonly IAutoActionFilter[] _filters;

        public AutoActionInvoker(IAutoActionFilter[] filters)
        {
            _filters = filters;
        }

        protected override FilterInfo GetFilters(ControllerContext controllerContext, ActionDescriptor actionDescriptor)
        {
            FilterInfo filters = base.GetFilters(controllerContext, actionDescriptor);

            foreach (IActionFilter filter in _filters)
            {
                filters.ActionFilters.Add(filter);
            }
            return filters;
        } 
    }
}