using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
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


            Test();

            //Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            //var task = GetResultsAsync();
            //task.Wait();




            Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            return View();
        }



        public async Task Test()
        {
            Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            Task t1 = ((Func<Task>)(async delegate
            {
                Console.WriteLine("Starting first async block");
                await Task.Delay(2000);
                var c = Thread.CurrentThread.ManagedThreadId;
                Console.WriteLine("Done first block");
            }))();
        }

        public Task GetResultsAsync()
        {
            var task = Task.Run(() =>
            {
                Console.WriteLine("Выводит самый последний метод в новом потоке с ID: " + Thread.CurrentThread.ManagedThreadId);


                Thread.Sleep(5000);
                var c = 10;
            });
            return task;
        }

        public async Task GetResultsAsync2()
        {
            await Task.Run(() =>
            {
                Console.WriteLine("Выводит самый последний метод в новом потоке с ID: " + Thread.CurrentThread.ManagedThreadId);


                Thread.Sleep(5000);
                var c = 10;
            });
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