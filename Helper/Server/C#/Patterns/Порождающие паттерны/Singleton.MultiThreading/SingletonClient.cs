using DoFactory.HeadFirst.Singleton.MultiThreading.Pattern;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading;

using System.Threading.Tasks;
namespace DoFactory.HeadFirst.Singleton.MultiThreading
{
    internal class SingletonClient
    {
        private static void Main(string[] args)
        {
            SingletonLazy obj = SingletonLazy.Instance;
            obj.Action();

            GenericSingleton();
        }

        private static void GenericSingleton()
        {
            FirstSingleton obj = FirstSingleton.Instance;
            obj.ShowSomething();
            Parallel.For(0, 10000, (i) =>
            {
                obj.ShowSomething();

            });
        }
    }

    /// <summary>
    /// ¬ажный момент: при использовании в своем классе необходимо объ€вить private конструктор, даже если он пустой.
    /// </summary>
    public sealed class FirstSingleton : Singleton<FirstSingleton>
    {
        public int Val = new Random().Next();
        private FirstSingleton() { }

        public void ShowSomething()
        {
            //Thread.Sleep(5);
            Console.WriteLine("Generic singleton " +Val+";  ThreadId: " + Thread.CurrentThread.ManagedThreadId);
        }
    }

}
