using System.Web.Mvc;
using GoodCode.DataBases;
using GoodCode.Interfaces;
using GoodCode.Repositories.MsSqlRepository;
using Microsoft.Practices.Unity;
using Unity.Mvc4;

namespace GoodCode
{
    public static class Bootstrapper
    {
        public static IUnityContainer Initialise()
        {
            var container = BuildUnityContainer();

            DependencyResolver.SetResolver(new UnityDependencyResolver(container));

            return container;
        }

        private static IUnityContainer BuildUnityContainer()
        {
            var container = new UnityContainer();

            // register all your components with the container here
            // it is NOT necessary to register your controllers

            // e.g. container.RegisterType<ITestService, TestService>();    
            RegisterTypes(container);

            return container;
        }

        public static void RegisterTypes(IUnityContainer container)
        {
            container.RegisterType<IRepository, MsSqlRepository>(new HierarchicalLifetimeManager());//at the end of the request is autimaticaly disose
            container.RegisterInstance(new AuthDBEntities(), new HierarchicalLifetimeManager());//ContainerControlledLifetimeManager
        }
    }
}