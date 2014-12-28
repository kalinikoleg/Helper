using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AbstractFactory
{
    public abstract class Travoyadnie { }
    public abstract class Plotoyadnie
    {
        public abstract void Eat(Travoyadnie travoyadnie);
    }

    //сам интерфейс абстрактной фабрики
    public abstract class ContinentFactory
    {
        public abstract Travoyadnie CreateTravoyadnie();
        public abstract Plotoyadnie CreatePlotoyadnie();
    }

    #region Continents

    //Возвращает реальных животных

    /// <summary>
    /// The 'ConcreteFactory1' class
    /// </summary>
    public class AfricaContinent : ContinentFactory
    {
        public override Travoyadnie CreateTravoyadnie()
        {
            return new Krolik();
        }

        public override Plotoyadnie CreatePlotoyadnie()
        {
            return new Lion();
        }
    }
    /// <summary>
    /// The 'ConcreteFactory2' class
    /// </summary>
    public class AmericaContinent : ContinentFactory
    {
        public override Travoyadnie CreateTravoyadnie()
        {
            return new Utka();
        }

        public override Plotoyadnie CreatePlotoyadnie()
        {
            return new Sobaka();
        }
    }
    #endregion


    //не абстрактными в это моделе явлюятся только последние классы, Звери, которые реализуют реальное поведение
    #region Звери
    public class Krolik : Travoyadnie { }

    public class Lion : Plotoyadnie
    {
        public override void Eat(Travoyadnie travoyadnie)
        {
            Console.WriteLine(this.GetType().Name + "едят " + travoyadnie.GetType().Name);
        }
    }

    public class Utka : Travoyadnie { }

    public class Sobaka : Plotoyadnie
    {
        public override void Eat(Travoyadnie travoyadnie)
        {
            Console.WriteLine(this.GetType().Name + "едят " + travoyadnie.GetType().Name);
        }
    }
    #endregion

    /// <summary>
    /// The 'Client' class 
    /// </summary>
    public class AnimalWord
    {
        private Travoyadnie _travoyadnie;
        private Plotoyadnie _plotoyadnie;

        public AnimalWord(ContinentFactory factory)
        {
            _travoyadnie = factory.CreateTravoyadnie();
            _plotoyadnie = factory.CreatePlotoyadnie();
        }

        public void RunFood()
        {
            _plotoyadnie.Eat(_travoyadnie);
        }
    }

   
    class Program
    {
        static void Main(string[] args)
        {
            ContinentFactory africa = new AfricaContinent();
            AnimalWord animals = new AnimalWord(africa);
            animals.RunFood();

            Console.ReadKey();
        }
    }
}
