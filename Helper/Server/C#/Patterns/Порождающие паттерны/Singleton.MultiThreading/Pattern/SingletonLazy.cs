using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DoFactory.HeadFirst.Singleton.MultiThreading.Pattern
{
    public sealed class SingletonLazy
    {
        private static readonly Lazy<SingletonLazy> _instance = new Lazy<SingletonLazy>(() => new SingletonLazy());

        private SingletonLazy() { }

        public static SingletonLazy Instance
        {
            get
            {
                return _instance.Value;
            }
        }

        public void Action()
        {
            Thread.Sleep(5);
            Console.WriteLine("Singleton action");
        }
    }
}
