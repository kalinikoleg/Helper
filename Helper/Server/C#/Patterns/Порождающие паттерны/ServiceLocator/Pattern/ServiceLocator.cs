using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ServiceLocatorPattern.Pattern
{
    public static class ServiceLocator
    {
        private readonly static Dictionary<Type, object> _configuredServices = new Dictionary<Type, object>();

        public static T GetConfiguredService<T>()
        {
            return (T)_configuredServices[typeof(T)];
        }

        public static void Register<T>(T service)
        {
            _configuredServices[typeof(T)] = service;
        }
    }
}
