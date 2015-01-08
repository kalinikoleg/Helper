
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Multiton.Pattern;

namespace Multiton
{

    class Program
    {
        static void Main(string[] args)
        {
            //Console.WriteLine("start......");
            //Parallel.For(0, 1000, (i) =>
            //{
            //    Pattern.Multiton obj1 = Pattern.Multiton.GetInstance("Oleg");
            //    Pattern.Multiton obj2 = Pattern.Multiton.GetInstance("Oleg");
            //    Pattern.Multiton obj3 = Pattern.Multiton.GetInstance("Oleg1");
            //    Pattern.Multiton obj4 = Pattern.Multiton.GetInstance("Oleg1");

            //    obj1.DoSomething();
            //    obj2.DoSomething();
            //    obj3.DoSomething();
            //    obj4.DoSomething();
            //});
            //Console.WriteLine("end......");

            //Generic

            Console.WriteLine("start......");
            Stopwatch watch = new Stopwatch();
            watch.Start();

            Parallel.For(0, 10000, (i) =>
            {
                var mul1 = MultitonGeneric<int>.GetInstance(1);
                var mul2 = MultitonGeneric<int>.GetInstance(2);
                mul1.DoSomething();
                mul2.DoSomething();
            });

            var c =new MultitonGeneric<int>();

            watch.Stop();
            Console.WriteLine("end...... Executed time: {0}", watch.Elapsed);

            Console.ReadKey();
        }
    }
}
