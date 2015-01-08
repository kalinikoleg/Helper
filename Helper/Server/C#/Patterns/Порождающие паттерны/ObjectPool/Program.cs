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
            Console.WriteLine("start......");


            //Create a high demand for MyClass objects.
            Parallel.For(0, 100, (i, loopState) =>
            {
                MyClass mc = pool.GetObject();
                // This is the bottleneck in our application. All threads in this loop
                // must serialize their access to the static Console class.
                Console.WriteLine("pool 1 :{0:####.##}  -> {1} Created: {2}; Added to pool: {3}", mc.GetValue(i), mc.GetValue(0), pool.CreatedObjectsCount, pool.AddedToPoolCount);
                pool.PutObject(mc);

            });
            Console.WriteLine("stop......");


            watchParallel.Stop();
            Console.WriteLine("Created: {0}; Added to pool: {1}, removed: {2}", pool.CreatedObjectsCount, pool.AddedToPoolCount, pool.RemovedObjectsFromBagCount);

            int count = GC.CollectionCount(0);
            Console.WriteLine("Сборок мусора " + count + ", время выполнения: " + watchParallel.Elapsed);
            Console.WriteLine("Press the Enter key to exit.");
            Console.ReadLine();
            GC.Collect();

            {
                Console.WriteLine("start......");
                count = GC.CollectionCount(0) - 1;
                Stopwatch watchOnlyThread = new Stopwatch();
                watchOnlyThread.Start();


                for (int i = 0; i < 1000; i++)
                {
                    MyClass mc = pool.GetObject();
                    // This is the bottleneck in our application. All threads in this loop
                    // must serialize their access to the static Console class.

                    Console.WriteLine("pool 2 :{0:####.##}  -> {0} -> {1} Created: {2}; Added to pool: {3}", mc.GetValue(i), mc.GetValue(0), pool.CreatedObjectsCount, pool.AddedToPoolCount);
                    pool.PutObject(mc);
                }


                watchOnlyThread.Stop();
                count = GC.CollectionCount(0) - count;
                Console.WriteLine("Сборок мусора " + count + ", время выполнения в одном потоке: " + watchOnlyThread.Elapsed);
                Console.WriteLine("pool 1 : Created: {0}; Added to pool: {1}, removed: {2}", pool.CreatedObjectsCount, pool.AddedToPoolCount, pool.RemovedObjectsFromBagCount);
                Console.ReadKey();
            }

            {
                Console.ReadKey();
                count = GC.CollectionCount(0) - 1;
                Stopwatch watchOnlyThread = new Stopwatch();
                watchOnlyThread.Start();



                for (int i = 0; i < 100; i++)
                {
                    MyClass mc = new MyClass();
                    // This is the bottleneck in our application. All threads in this loop
                    // must serialize their access to the static Console class.
                    Console.WriteLine("{0:####.##}  -> {1}", mc.GetValue(i), mc.GetValue(0));
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
