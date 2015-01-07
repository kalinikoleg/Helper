using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading;
using ObjectPool.Pattern;
using System.Threading.Tasks;
using System.Collections.Concurrent;

namespace ObjectPool
{
    class Program
    {
        private static void Main(string[] args)
        {

            ObjectPool<MyClass> pool = new ObjectPool<MyClass>(() => new MyClass());

            Stopwatch watchParallel = new Stopwatch();
            watchParallel.Start();

            // Create a high demand for MyClass objects.
            Parallel.For(0, 10000, (i, loopState) =>
            {
                MyClass mc = pool.GetObject();
                // This is the bottleneck in our application. All threads in this loop
                // must serialize their access to the static Console class.
                Console.WriteLine("{0:####.##}  -> {1}", mc.GetValue(i), mc.GetValue(0));
                pool.PutObject(mc);

            });

            watchParallel.Stop();

            int count = GC.CollectionCount(0);
            Console.WriteLine("Сборок мусора " + count + ", время выполнения: " + watchParallel.Elapsed);
            Console.WriteLine("Press the Enter key to exit.");
            Console.ReadLine();
            GC.Collect();

            {

                count = GC.CollectionCount(0) - 1;
                Stopwatch watchOnlyThread = new Stopwatch();
                watchOnlyThread.Start();

                for (int i = 0; i < 10000; i++)
                {
                    MyClass mc = pool.GetObject();
                    // This is the bottleneck in our application. All threads in this loop
                    // must serialize their access to the static Console class.
                    Console.WriteLine("{0:####.##}  -> {1}", mc.GetValue(i), mc.GetValue(0));
                    pool.PutObject(mc);
                }

                watchOnlyThread.Stop();
                count = GC.CollectionCount(0) - count;
                Console.WriteLine("Сборок мусора " + count + ", время выполнения в одном потоке: " + watchOnlyThread.Elapsed);
            }

            {

                count = GC.CollectionCount(0) - 1;
                Stopwatch watchOnlyThread = new Stopwatch();
                watchOnlyThread.Start();

                for (int i = 0; i < 10000; i++)
                {
                    MyClass mc = pool.GetObject();
                    // This is the bottleneck in our application. All threads in this loop
                    // must serialize their access to the static Console class.
                    Console.WriteLine("{0:####.##}  -> {1}", mc.GetValue(i), mc.GetValue(0));
                    pool.PutObject(mc);
                }

                watchOnlyThread.Stop();
                count = GC.CollectionCount(0) - count;
                Console.WriteLine("Сборок мусора " + count + ", время выполнения в одном потоке: " + watchOnlyThread.Elapsed);
            }
        }


        class MyClass
        {
            public int[] Nums { get; set; }
            public double GetValue(long i)
            {
                return Math.Sqrt(Nums[i]);
            }
            public MyClass()
            {
                Nums = new int[1000000];
                Random rand = new Random();
                for (int i = 0; i < Nums.Length; i++)
                    Nums[i] = rand.Next();
            }
        }
    }
}
