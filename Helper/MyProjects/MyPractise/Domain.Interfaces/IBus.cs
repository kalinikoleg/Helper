#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using MyPractise.Entities;

#endregion

namespace Domain.Interfaces
{
    public interface IBus
    {
        bool Send(ShipOrderMessage message);
    }
}
