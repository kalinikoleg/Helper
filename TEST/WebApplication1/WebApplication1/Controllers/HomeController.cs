using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace WebApplication1.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {

            Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            var t = Task.Run(async () => await Test3());


            t.Wait();



            return View();
        }


        public async Task Test()
        {
            Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            Task t1 =((Func<Task>)(async delegate
            {
                Console.WriteLine("Starting first async block");
                await Task.Delay(0);
                var c = Thread.CurrentThread.ManagedThreadId;
                Console.WriteLine("Done first block");
            }))();
        }


        public async Task Test2()
        {
            await Task.Run(() =>
            {
                Thread.Sleep(1000);
            });

            Thread.Sleep(5000);
        }

        public async Task Test3()
        {
             await Test2();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}