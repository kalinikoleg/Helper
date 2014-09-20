using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Mvc;
using AutoMapper;
using MyPractise.Controllers.Base;
using MyPractise.Exstentions;

namespace MyPractise.Controllers
{
    public class MapperController : BaseController
    {
        public ActionResult Index()
        {
            //from Source to Destination
            Mapper.CreateMap<Source, Destination>();

            var source = new Source() { Child = new Child() { Number = 4 } };
            //from - to
            Destination dest = Mapper.Map<Source, Destination>(source);
            // <=>
            Destination dest1 = Mapper.Map<Destination>(source);


            //Так  как  наше  свойство  назначения  называется  ChildNumber, 
            //AutoMapper будет преобразовывать Child.Number.
            string number = dest.ChildNumber;
            return View();
        }

        public ViewResult Test()
        {
            var source = new Source() { Child = new Child() { Number = 4 } };
            return AutoMappedView<Destination>(source);
        }
    }



    
    public class Source
    {
        public Child Child { get; set; }
    }

    public class Child
    {
        public int Number { get; set; }
    }
    public class Destination
    {
        public string ChildNumber { get; set; }
    }
}