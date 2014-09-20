using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace Attributes
{
    internal delegate string StrMod(string str);

    internal delegate void StrModStatic(ref string str);

    internal class StringOps
    {
        public string ReplaceSpaces(string s)
        {
            Console.WriteLine("Замена пробелов дефисами");
            return s.Replace('-', ' ');
        }

        public string RemoveSpaces(string s)
        {
            string temp = string.Empty;
            int i;
            Console.WriteLine("Удаление пробелов.");

            for (int j = 0; j < s.Length; j++)
            {
                if (s[j] != ' ')
                {
                    temp += s[j];
                }
            }
            return temp;
        }
    }

    internal static class StringOpsStatic
    {
        public static void  ReplaceSpaces(ref string s)
        {
            Console.WriteLine("Замена пробелов дефисами");
            s = s.Replace('-', ' ');
        }

        public static void RemoveSpaces(ref string s)
        {
            string temp = string.Empty;
            int i;
            Console.WriteLine("Удаление пробелов.");

            for (int j = 0; j < s.Length; j++)
            {
                if (s[j] != ' ')
                {
                    temp += s[j];
                }
            }
            s =  temp;
        }
    }
}
