using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Builder.PhoneExample
{
    /// <summary>
    /// This is the "Product" class
    /// </summary>
    public class MobilePhone
    {
        // fields to hold the part type
        string phoneName;
        ScreenType phoneScreen;
        Battery phoneBattery;
        OperatingSystem phoneOS;
        Stylus phoneStylus;

        public MobilePhone(string name)
        {
            phoneName = name;
        }

        // Public properties to access phone parts

        public string PhoneName
        {
            get { return phoneName; }
        }

        public ScreenType PhoneScreen
        {
            get { return phoneScreen; }
            set { phoneScreen = value; }
        }

        public Battery PhoneBattery
        {
            get { return phoneBattery; }
            set { phoneBattery = value; }
        }

        public OperatingSystem PhoneOS
        {
            get { return phoneOS; }
            set { phoneOS = value; }
        }

        public Stylus PhoneStylus
        {
            get { return phoneStylus; }
            set { phoneStylus = value; }
        }

        // Method to display phone details in our own representation
        public override string ToString()
        {
            return string.Format("Name: {0}\nScreen: {1}\nBattery {2}\nOS: {3}\nStylus: {4}",
                PhoneName, PhoneScreen, PhoneBattery, PhoneOS, PhoneStylus);
        }

        public void ShowProduct()
        {
            Console.WriteLine(ToString());
        }
    }
}
