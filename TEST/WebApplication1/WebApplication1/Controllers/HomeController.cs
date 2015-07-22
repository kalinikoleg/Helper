using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
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
        public async Task<ActionResult> Index()
        {
            startButton_Click();



            //конец метода с. 68
            return View();
        }


        private void LookupHostName()
        {
            Task<IPAddress[]> IPAddressPromisse = Dns.GetHostAddressesAsync("oreilly.com");



            IPAddressPromisse
                .ContinueWith(_ =>
                {
                    IPAddress[] ipAddresses = IPAddressPromisse.Result;
                }).Wait();
        }


        public async Task Test()
        {
            Console.WriteLine("Основной поток с ID: " + Thread.CurrentThread.ManagedThreadId);
            Task t1 = ((Func<Task>)(async delegate
            {
                Console.WriteLine("Starting first async block");
                await Task.Delay(0);
                var c = Thread.CurrentThread.ManagedThreadId;
                Console.WriteLine("Done first block");
            }))();
        }


        public async void startButton_Click()
        {
            // ONE
            Task<int> getLengthTask = AccessTheWebAsync();

            // FOUR
            var c = "test";

            getLengthTask.ContinueWith(_ => { });
            // FIVE
            int contentLength = await getLengthTask;

            // SEVEN
            Trace.WriteLine(String.Format("\r\nLength of the downloaded string: {0}.\r\n", contentLength));
        }

        async Task<int> AccessTheWebAsync()
        {
            // TWO
            HttpClient client = new HttpClient();
            Task<string> getStringTask =
                client.GetStringAsync("http://msdn.microsoft.com");

            // THREE      
            Task task2 = Test2();
            //   await task2;
            string urlContents = await getStringTask;



            // SIX
            return urlContents.Length;
        }


        public async Task Test2()
        {
            await Task.Delay(5000);

            Thread.Sleep(1000);
        }

        public async Task Test3()
        {
            await Test2();

            var c = 10;
        }

    }
}