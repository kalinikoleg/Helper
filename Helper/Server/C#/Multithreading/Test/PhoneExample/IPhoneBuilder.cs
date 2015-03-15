using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Builder.PhoneExample;

namespace Builder.PhoneExample
{
    /// <summary>
    /// This is the "Builder" interface
    /// </summary>
    public interface IPhoneBuilder
    {
        void BuildScreen();
        void BuildBattery();
        void BuildOS();
        void BuildStylus();
        MobilePhone Phone { get; }
    }


}
