using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

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
                    Thread.Sleep(1000*r.Next(5));
                    Console.WriteLine("{0}, ", i);
                }
            }
            Console.WriteLine();
        }


    }
    internal class Program
    {
        static void Main(string[] args)
        {

            Printer p = new Printer();
            

            Thread[] threads = new Thread[10];

            for (int i = 0; i < 10; i++)
            {
                threads[i] = new Thread(new ThreadStart(p.PrintNumbres));
                threads[i].Name = string.Format("Worker thread #{0}", i);
            }

            foreach (Thread t in threads)
            {
                t.Start();
            }
            Console.ReadLine();

            Console.WriteLine(" Main() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);

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
