using System;
namespace Decorator
{
    //component
    //IButton через интерфейс нельзя делать, потому что декоратор добавляет доп поведение только к одному объекту
    public abstract class Button
    {
        public abstract void Click();
    }

    //Реальная кнопка, к которой добавим функционал 
    public class RealButton : Button
    {
        public override void Click()
        {
            Console.WriteLine("Click on the real button without resizing......");
        }
    }

    //реализация патерна
    public class BigAndRedBorederDecorator : Pattern.Decorator
    {
        public override void Click()
        {
            base.Click();
            //добавил дополнительное поведение к кнопке
            ResizeButton();
            MakeRedBorder();
            Console.WriteLine("Added any behaviour for button....");
        }

        public override void Test()
        {
            ResizeButton();
            base.Test();
        }

        public void MakeRedBorder()
        {
            Console.WriteLine("Made red border of button....");
        }
        public void ResizeButton()
        {
            Console.WriteLine("ResizedButton....");
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            RealButton button = new RealButton();
            BigAndRedBorederDecorator dec = new BigAndRedBorederDecorator();

            dec.SetButton(button);
            dec.Click();
            dec.Test();

            Console.ReadKey();
        }
    }
}
