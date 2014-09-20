#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Domain.Interfaces;
using MyPractise.Controllers.Base;
using MyPractise.Entities;

#endregion

namespace MyPractise.Controllers
{
    public class ShinaController : BaseController
    {
        private readonly IBus _bus;

        public ShinaController(IBus bus)
        {
            _bus = bus;
        }


        public ActionResult Index()
        {
            var message = new ShipOrderMessage()
            {
                OrderId = 10
            };
            _bus.Send(message);

            return View();
        }

    }
}
