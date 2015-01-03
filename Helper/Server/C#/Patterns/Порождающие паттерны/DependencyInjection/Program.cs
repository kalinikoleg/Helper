using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DependencyInjection.Pattern;

namespace DependencyInjection
{
   
    public class Bazuka : IWeapon
    {
        public void Kill()
        {
            Console.WriteLine("BIG BADABUM!");
        }
    }
    public class Sword : IWeapon
    {
        public void Kill()
        {
            Console.WriteLine("Chuk-chuck");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Warrior war = new Warrior(new Bazuka());
            war.Kill();
        }
    }
}
