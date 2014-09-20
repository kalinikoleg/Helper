using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AutoMapper;
using MyPractise.Controllers;

namespace MyPractise.Exstentions
{
    public class AutoMappedViewResult : ViewResult
    {
        public Type DestinationType { get; set; }
        public Type ViewModelType { get; set; }

        public static Func<object, Type, Type, object> Map = (model, from, to) =>
        {
            return  Mapper.Map(model, from, to);
        };

        public AutoMappedViewResult(Type type)
        {
            DestinationType = type;
        }

        public override void ExecuteResult(ControllerContext context)
        {
            ViewData.Model = Map(ViewData.Model, ViewData.Model.GetType(), DestinationType);
            base.ExecuteResult(context);
        }
    }
}