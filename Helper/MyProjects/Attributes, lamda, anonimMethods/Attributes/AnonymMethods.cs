#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

#endregion

namespace Attributes
{
    internal delegate void CountIt();

    internal delegate void CountItWithParameter(int end);

    internal delegate int CountItWithParameterAndReturnValue(int end);


}
