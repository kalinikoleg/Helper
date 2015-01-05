using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Multiton
{


    class Program
    {
        static void Main(string[] args)
        {
            Pattern.Multiton obj1 = Pattern.Multiton.GetInstance("Oleg");

            obj1.DoSomething();
        }
    }
}
