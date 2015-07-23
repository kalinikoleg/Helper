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


    //исключения
    public class HomeController : Controller
    {
        public delegate void SetBoolValue();

        public SetBoolValue setBoolValue = null;

        public async Task<ActionResult> Index()
        {


            var context = SynchronizationContext.Current;


            var task = FirstDeep2Copy();


            await Task.WhenAll(task);

            return View();



            //разобраться
            //  Task t = Task.Factory.StartNew(() => MyLongComputation(a, b), cancellationToken, TaskCreationOptions.LongRunning, taskScheduler);
 

            //с.70     понять точно, почему переключается поток
            // await Task.Delay(delay);
            // var response = await query.ExecuteNextAsync<T>();
        }

        //Main
        public Task<bool> LastDeep2()
        {
            {
                /*  var task = LastDeep2();
                  setBoolValue();

                  if (await task)
                  {
                      var c = 10;
                  }   */
            }

            TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();

            //создать диалог, через 5 сек пользвотель закроет диалог и нужно сделать задачу завершившийся
            setBoolValue += delegate
            {
                Thread.Sleep(1000);
                var cxx = Thread.CurrentThread.ManagedThreadId;
                tcs.SetResult(true);
            };

            return tcs.Task;
        }

        public async Task FirstDeep2Copy()
        {
            await LastDeep2Copy();

            // callback
            for (int i = 0; i < 3; i++)
            {
                var c = 10;
            }
        }

        public Task LastDeep2Copy()
        {
            return Task.Run(() =>
            {
                for (int i = 0; i < 2; i++)
                {
                    var c = 1;
                }
            });
        }


        private void LookupHostName()
        {
            Task<IPAddress[]> IPAddressPromisse = Dns.GetHostAddressesAsync("oreilly.com");


            //тоже самое делает await, весь код после него оборачивается в ContinueWith
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



        public async Task StartExanmples()
        {

            await FirstDeep();

            // call back
            Thread.Sleep(1000);
        }


        public async Task FirstDeep()
        {
            await LasrDeep();

            // call back
            Thread.Sleep(1000);

            await LasrDeep();
            // call back
            Thread.Sleep(1000);
        }

        public async Task LasrDeep()
        {
            // если поставить await, то будет deadlock, разобраться почему это происходит
            Task.Run(() =>
            {
                Thread.Sleep(1000);
            });


            // call back
            Thread.Sleep(1000);

        }




        public async void startButton_Click()
        {
            // ONE
            Task<int> getLengthTask = AccessTheWebAsync();

            // FOUR
            var c = "test";

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
            //   Task task2 = Test2();
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