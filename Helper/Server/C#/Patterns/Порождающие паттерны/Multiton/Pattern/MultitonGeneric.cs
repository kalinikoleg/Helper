using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Multiton.Pattern
{
    //Пул одиночек
    public sealed class MultitonGeneric<TKey>
    {
        //faster than Dictionary
        private static ConcurrentDictionary<TKey, MultitonGeneric<TKey>> _instance = new ConcurrentDictionary<TKey, MultitonGeneric<TKey>>();

        private Guid _hardwareId = Guid.NewGuid();

        private MultitonGeneric(TKey key) { /* SKIPPED */ }

        public static MultitonGeneric<TKey> GetInstance(TKey key)
        {
            MultitonGeneric<TKey> instance = null;

            //this operation is lock-free
            if (_instance.TryGetValue(key, out instance)) return instance;

            return _instance.GetOrAdd(key, new MultitonGeneric<TKey>(key));

        }

        public Guid HarwareId { get { return _hardwareId; } }

        public void DoSomething()
        {
            Console.WriteLine(HarwareId);
        }
    }
}
