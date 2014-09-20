using System;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyPractise.Controllers;

namespace UnitTestWebSite
{

    //page 84 after implementaion Login in
    [TestClass]
    public class Examples
    {
        [TestMethod]
        public void TestMethod1()
        {
            //Arrange
            HomeController controller = new HomeController();

            //Act 
            ViewResult result = controller.Index() as ViewResult;

            //Assert
            Assert.IsNotNull(result);
        }

        [TestMethod]
        public void Index()
        {
            //Arrange
            HomeController controller = new HomeController();

            //Act 
            ViewResult result = controller.Index() as ViewResult;

            //Assert
            Assert.AreEqual("UnitTest", result.ViewBag.Message);
        }
    }
}
