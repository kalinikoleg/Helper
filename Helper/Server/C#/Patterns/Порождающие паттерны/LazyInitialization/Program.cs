using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;
using LazyInitialization.Pattern;

namespace LazyInitialization
{
    class Test
    {
        int[] _array;
        public Test()
        {
            Console.WriteLine("Test()");
            _array = new int[10];
        }
        public int Length
        {
            get
            {
                return _array.Length;
            }
        }
    }

    
    class Program
    {
      
        static void Main(string[] args)
        {
            Customer cus = new Customer("5465");
            //сейчас  _orders не создан, в него записан только делегат по созданию объекта.
            //Делегат выполнится только тогда, когда вызовится метод  _orders.Value
            //
            var c = cus.MyOrders;




            //One more example
            // Create Lazy.
            Lazy<Test> lazy = new Lazy<Test>();

            // Show that IsValueCreated is false.
            Console.WriteLine("IsValueCreated = {0}", lazy.IsValueCreated);

            // Get the Value.
            // ... This executes Test().
            Test test = lazy.Value;

            // Show the IsValueCreated is true.
            Console.WriteLine("IsValueCreated = {0}", lazy.IsValueCreated);

            // The object can be used.
            Console.WriteLine("Length = {0}", test.Length);
        }
    }
}
