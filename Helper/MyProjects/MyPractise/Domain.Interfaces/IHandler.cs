#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyPractise.Entities;

#endregion

namespace Domain.Interfaces
{
    public interface IHandler<T>
    {
        Result Handle(T message);
    }
}
