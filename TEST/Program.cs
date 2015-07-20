using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Builder
{

    public delegate int BinaryOp(int x, int y);

    public class Printer
    {
        public void PrintNumbres()
        {
            //одновременно получается доступ с 10 потоков к одному и тому же объекту
            //выводит тот первый, кто успел 
            lock (this)
            {
                Console.WriteLine(Thread.CurrentThread.Name);
                for (int i = 0; i < 10; i++)
                {
                    Random r = new Random();
                    Thread.Sleep(1000 * r.Next(5));
                    Console.WriteLine("{0}, ", i);
                }
            }
            Console.WriteLine();
        }


    }

    public class Test
    {

        public async void TestMethod()
        {

            var c = Thread.CurrentThread.ManagedThreadId;
            var s = await DoWorkAsync();
            Console.WriteLine(string.Format("saas{0}", s));
            var s1 = await DoWorkAsync();
            var c3 = Thread.CurrentThread.ManagedThreadId;
        }


        private Task<string> DoWorkAsync()
        {
            return Task.Run(() =>
            {
                Thread.Sleep(5000);
                Console.Beep();
                return "do with work";
            });
        }



        public async void TTTT()
        {
            var c3 = Thread.CurrentThread.ManagedThreadId;

            await Task.Run(() => { Thread.Sleep(2000); });
            MessageBox.Show("first done");

            await Task.Run(() => { Thread.Sleep(2000); });
            MessageBox.Show("second done");

            await Task.Run(() => { Thread.Sleep(2000); });
            MessageBox.Show("the third done");
        }

    }


    public class Car
    {
        protected string Name { get; set; }
        protected string PaintColor { get; set; }

        protected string Body { get; set; }

        public void Paint()
        {
            Console.WriteLine("Painting.....");
        }

        public void InstallEngine()
        {
            Console.WriteLine("instaling the engine");
        }
    }

    public class Golf : Car
    {
        public Golf()
        {
            Name = "Golf";
            Body = "Hatchback";
        }
    }

    public class Passat : Car
    {
        public Passat()
        {
            Name = "Passat";
            Body = "Hatchback";
        }
    }

    internal class Program
    {


        static void Main(string[] args)
        {

            #region Main
            int[] source = Enumerable.Range(1, 100).ToArray();
            List<int> neList = new List<int>();

            Parallel.Invoke(() =>
            {
                Thread.Sleep(2000);
                Console.WriteLine("1). Id: " + Thread.CurrentThread.ManagedThreadId);
            },
            () =>
            {
                Thread.Sleep(2000);
                Console.WriteLine("1). Id: " + Thread.CurrentThread.ManagedThreadId);
            }
            );
            Task task = Task.Factory.StartNew(() =>
            {
                Console.Beep(50, 5);

                // Thread.Sleep(2000);
                Console.WriteLine("first: Id: " + Thread.CurrentThread.ManagedThreadId);
            });

            var tasks = new[]
            {
                Task.Factory.StartNew(() =>
                {
                    Thread.Sleep(2000);
                    Console.WriteLine("1). Id: " + Thread.CurrentThread.ManagedThreadId);
                }),
                Task.Factory.StartNew(() =>
                {
                    Thread.Sleep(2000);
                    Console.WriteLine("2). Id: " + Thread.CurrentThread.ManagedThreadId);
                }),
                Task.Factory.StartNew(() =>
                {
                    Thread.Sleep(2000);
                    Console.WriteLine("3). Id: " + Thread.CurrentThread.ManagedThreadId);
                })

            };

            for (int i = 0; i < 5; i++)
            {
                Thread.Sleep(10000);
            }

            Task.WaitAll(tasks);
            task.Wait();

            #endregion




        }


    }
}
