using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GoodCode.DataBases;
using GoodCode.Interfaces;
using GoodCode.Models;


namespace GoodCode.Controllers
{
    public class HomeController : BaseController
    {
        private readonly IRepository Repository;

        public HomeController(IRepository rep)
        {
            Repository = rep;
        }

        public ActionResult Index()
        {
            var cc = Repository.Users;
            var c = Repository.GetUserByEmail("oleg_kalinik@mail.ru");
            return View();
        }
    }

   

}



 /*public IReadOnlyList<User> Get()
        {

            AuthDBEntities dbcontext = new AuthDBEntities();
            return dbcontext.GetUsers().Select(z => new User()
            {
                ID = z.ID
            }).ToList();
        }*/