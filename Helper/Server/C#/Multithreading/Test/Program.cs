using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Builder
{

    public delegate int BinaryOp(int x, int y);
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(" Main() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);

            BinaryOp op = new BinaryOp(Add);
            IAsyncResult asy = op.BeginInvoke(10, 10, null, null);

            Console.WriteLine(" Doing more work in Main()");

            int answer = op.EndInvoke(asy);

            Console.WriteLine(" Result: {0}", answer);

            Console.ReadLine();
        }


        public static int Add(int x, int y)
        {
            Console.WriteLine(" Add() invoked on thread {0}", Thread.CurrentThread.ManagedThreadId);




            Thread.Sleep(10000);
            return x + y;
        }
    }
}
