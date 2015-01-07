using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace LazyInitialization.Pattern
{
    public class Orders
    {
        public Orders(string orderId)
        {
            Id = orderId;
        }
        public string Id { get; set; }
    }

    class Customer
    {
        private Lazy<Orders> _orders;
        public string CustomerID { get; private set; }
        public Customer(string id)
        {
            CustomerID = id;
            _orders = new Lazy<Orders>(() =>
            {
                // You can specify any additonal  
                // initialization steps here. 
                return new Orders(this.CustomerID);
            }, LazyThreadSafetyMode.None);
        }

        public Orders MyOrders
        {
            get
            {
                // Orders is created on first access here. 
                return _orders.Value;
            }
        }
    }
}
