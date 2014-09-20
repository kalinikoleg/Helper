#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

#endregion

namespace MyPractise.Controllers.Factory
{
    public class ControllerFactory : DefaultControllerFactory
    {
        public static Func<Type, object> GetInstance = type => Activator.CreateInstance(type);

        protected override IController GetControllerInstance(RequestContext requestContext, Type controllerType)
        {
            if (controllerType != null)
            {
                var controller = (Controller) GetInstance(controllerType);
                controller.ActionInvoker =
                    (IActionInvoker) GetInstance(typeof (AutoActionInvoker));
                return controller;
            }
            return null;
        }
    }
}