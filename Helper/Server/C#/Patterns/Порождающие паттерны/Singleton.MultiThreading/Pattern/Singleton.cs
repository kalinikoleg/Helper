using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace DoFactory.HeadFirst.Singleton.MultiThreading.Pattern
{
    /// <summary>
    /// Expected private constructor for create object
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class Singleton<T> where T : class
    {
        private static Lazy<T> _instance =
            new Lazy<T>(
                () =>
                   (T)typeof(T).GetConstructor(BindingFlags.Instance | BindingFlags.NonPublic,
                        null, new Type[0], null).Invoke(null)
                );


        public static T Instance
        {
            get { return _instance.Value; }
        }
    }
}
