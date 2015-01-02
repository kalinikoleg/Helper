using System;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Runtime.Remoting.Messaging;
using System.Security.Policy;
using System.Threading;
using System.Threading.Tasks;

namespace DoFactory.HeadFirst.Singleton.MultiThreading
{
    public class Singleton<T> where T : class
    {
        private static T _instance;

        protected Singleton()
        {
        }

        private static T CreateInstance()
        {
            ConstructorInfo cInfo = typeof(T).GetConstructor(
                BindingFlags.Instance | BindingFlags.NonPublic,
                null,
                new Type[0],
                new ParameterModifier[0]);

            return (T)cInfo.Invoke(null);
        }

        public static T Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = CreateInstance();
                }

                return _instance;
            }
        }
    }

    internal class SingletonClient
    {
        private static void Main(string[] args)
        {
            //проблему видно только в debugger только с классом Singleton, с классом EagerSingleton разбирается CLR
            Parallel.Invoke(
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); },
                () => { Singleton.getInstance().SaySomething(); });

            // Wait for user
            Console.ReadKey();
        }
    }

    #region Singleton

    public class Singleton
    {
        private static Singleton _uniqueInstance;
        private static readonly object _syncLock = new Object();
        private static int g;

        // other useful instance variables here

        private Singleton() { }

        public static Singleton getInstance()
        {
            //Lock entire body of method
            lock (_syncLock)
            {
                if (_uniqueInstance == null)
                {
                    _uniqueInstance = new Singleton();
                    Random s = new Random();

                    //отключить блокировку и видно разные значения только в Debugger
                    g = s.Next();
                }
                return _uniqueInstance;
            }
        }

        // other useful methods here
        public void SaySomething()
        {
            Console.WriteLine("Guid:{0}", g);
            Console.WriteLine("Thread Id:{0}", Thread.CurrentThread.ManagedThreadId);
        }
    }

    sealed class EagerSingleton
    {
        // CLR eagerly initializes static member when class is first used
        // CLR guarantees thread safety for static initialisation
        private static readonly EagerSingleton _instance = new EagerSingleton();
        private static int g = new Random().Next();
        // Note: constructor is private
        private EagerSingleton()
        {
        }

        public static EagerSingleton getInstance()
        {
            return _instance;
        }

        public void SaySomething()
        {
            Thread.Sleep(5);
            //Console.WriteLine("Thread Id:{0}", Thread.CurrentThread.ManagedThreadId);
        }
    }
    #endregion
}
