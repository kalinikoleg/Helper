using System.Configuration;
using System;

namespace CustomConfigApp
{
    class Program
    {
        static void Main(string[] args)
        {
            ConfigHelper section = (ConfigHelper)ConfigurationManager.GetSection("FilterHashKey");
            if (section != null)
            {
                foreach(FilterHashElement element in section.HashKeys)
                    Console.WriteLine(String.Format("Key {0}, Value {1} ", element.Key, element.Value));

                Console.WriteLine("\nPress any key to exit...");
                Console.ReadLine();
            }
        }
    }
}
