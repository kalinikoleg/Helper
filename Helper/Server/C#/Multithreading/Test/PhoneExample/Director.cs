using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Builder.PhoneExample
{
    // This is the "Director" class - распорядитель
    public class Director
    {
        public void Build(IPhoneBuilder phoneBuilder)
        {
            phoneBuilder.BuildBattery();
            phoneBuilder.BuildOS();
            phoneBuilder.BuildScreen();
            phoneBuilder.BuildStylus();
        }
    }

}
