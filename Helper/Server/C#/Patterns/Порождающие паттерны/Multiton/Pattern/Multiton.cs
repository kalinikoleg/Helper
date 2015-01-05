using System;
using System.Collections.Concurrent;
using System.Net.NetworkInformation;

namespace Multiton.Pattern
{
    public sealed class Multiton
    {
        private static readonly  ConcurrentDictionary<string,Multiton> _instance 
            = new ConcurrentDictionary<string, Multiton>();

        // запретить создание экземпляров из вне
        private Multiton(string key) { }

        public static Multiton GetInstance(string key)
        {
            return Multiton._instance.GetOrAdd(key, (x) => new Multiton(x));
        }

        public void DoSomething()
        {
            Console.WriteLine("Hello");
        }
    }
}
