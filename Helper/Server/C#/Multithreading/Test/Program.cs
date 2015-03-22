using System;
using System.Collections.Generic;
using System.Linq;
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

             Task.Run(() => { Thread.Sleep(2000); });
            MessageBox.Show("second done");

             Task.Run(() => { Thread.Sleep(2000); });
            MessageBox.Show("the third done");
        }

    }


    internal class Program
    {
        static void Main(string[] args)
        {
            var c = Thread.CurrentThread.ManagedThreadId;
            var res = new Test();
            res.TestMethod();
            //написать код, чтобы не получать void, а какое-то значение
            Task.WaitAll();
            Console.ReadKey();
            res.TTTT();
            var c3 = Thread.CurrentThread.ManagedThreadId;
            //async - означает, что данный метод должен вызываться в неблокирующей манере
            //если метод декорируется ключем словом async, , но не имеет хотя бы одного 
            //внутреннего вызова метода с применением await, получается блокирующий, синхронный вызов

            //Как только встретилось выражение await, вызывающий вызывающий поток приостанавливается вплоть до
            //завершения ожидаемой задачи. тем временем управление возвращается коду, вызывавшему метод

            //Методы(лямда-выражения, анонимные метода), помеченные ключевым словом async, будут выполняться в блокирующей манере 
            //до тех пор, пока не встретят ключевое слово await



            ////Printer p = new Printer();


            ////Thread[] threads = new Thread[10];

            ////for (int i = 0; i < 10; i++)
            ////{
            ////    threads[i] = new Thread(new ThreadStart(p.PrintNumbres));
            ////    threads[i].Name = string.Format("Worker thread #{0}", i);
            ////}

            ////foreach (Thread t in threads)
            ////{
            ////    t.Start();
            ////}
            ////Console.ReadLine();

            ////Console.WriteLine(" Main() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);

            //BinaryOp op = new BinaryOp(Add);
            //IAsyncResult asy = op.BeginInvoke(10, 10, MyAsyncMethod, null);

            //Console.WriteLine(" Doing more work in Main()");

            //int answer = op.EndInvoke(asy);

            //Console.WriteLine(" Result: {0}", answer);

            //Console.ReadLine();
        }


        public static void MyAsyncMethod(IAsyncResult ifar)
        {
            var del = ((AsyncResult)ifar).AsyncDelegate;
            BinaryOp bin = (BinaryOp)del;
            bin.EndInvoke(ifar);

            Console.Beep();
        }

        public static int Add(int x, int y)
        {

            Console.WriteLine(" Add() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);

            Thread.Sleep(5000);
            return x + y;
        }
    }
}
