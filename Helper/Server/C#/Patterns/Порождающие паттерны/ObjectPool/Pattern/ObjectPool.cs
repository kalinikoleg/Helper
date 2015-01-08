using System;
using System.Collections.Concurrent;
using System.Xml.Serialization;

namespace ObjectPool.Pattern
{
    public class ObjectPool<T>
    {
        private static int _createdObjects = 0;
        private static int _addedToPool = 0;
        private static int _removedObjectsCount = 0;
        private ConcurrentBag<T> _objects; 
        private Func<T> _objectGenerator;

        public ObjectPool(Func<T> objectGenerator)
        {
            if (objectGenerator == null) throw new ArgumentNullException("objectGenerator");
            _objects = new ConcurrentBag<T>();
            _objectGenerator = objectGenerator;
        }

        public T GetObject()
        {
            T item;
            if (_objects.TryTake(out item))
            {
                _removedObjectsCount++;
                return item;
            }
            _createdObjects++;
            return _objectGenerator();
        }


        public void PutObject(T item)
        {
            _addedToPool++;
            _objects.Add(item);
        }

        public int CreatedObjectsCount
        {
            get { return _createdObjects; }
        }
        public int AddedToPoolCount
        {
            get { return _addedToPool; }
        }

        public int RemovedObjectsFromBagCount
        {
            get { return _removedObjectsCount; }
        }
    }
}
