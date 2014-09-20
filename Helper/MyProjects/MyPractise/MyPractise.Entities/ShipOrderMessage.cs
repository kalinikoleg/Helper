#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyPractise.Entities.Abstract;

#endregion

namespace MyPractise.Entities
{
    public class ShipOrderMessage : BaseEntity
    {
        public long OrderId { get; set; }
    }
}
