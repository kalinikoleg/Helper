﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ServiceLocator
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


    public class Customer
    {
    }

    public interface ICustomerService
    {
        Customer GetCustomer(int id);
    }

    public interface ICustomerRepository
    {
        Customer GetCustomerFromDatabase(int id);
    }

    public class CustomerRepository : ICustomerRepository
    {
        public Customer GetCustomerFromDatabase(int id)
        {
            return new Customer();
        }
    }

    public class CustomerService : ICustomerService
    {
        private ICustomerRepository _customerRepository;
        public CustomerService()
        {
            _customerRepository = ServiceLocator.GetConfiguredService<ICustomerRepository>();
        }

        public Customer GetCustomer(int id)
        {
            return _customerRepository.GetCustomerFromDatabase(5);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            ServiceLocator.Register<ICustomerRepository>(new CustomerRepository());

            Customer cust = new CustomerService().GetCustomer(2);
        }
    }
}
