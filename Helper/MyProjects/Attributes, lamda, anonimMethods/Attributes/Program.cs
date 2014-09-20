#define TRIAL
//#define RELEASE

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using Timer = System.Threading.Timer;


namespace Attributes
{
    #region ConditionalAttribute
    //#DEFINE only with this

    internal class Test
    {
        [Conditional("TRIAL")]
        public void Trial()
        {
            Console.WriteLine("вывыдет TRIAL если определна директива TRIAL");
        }

        [Conditional("RELEASE")]
        public void Release()
        {
            Console.WriteLine("вывыдет Release если определна директива Release");
        }
    }


    #endregion

    #region ObsoluteAttribute
    //помечает, как устаревший

    internal class TestObsoluteAttribute
    {
        [Obsolete("этот метод устаревший, лучше использовать GetValue2")]
        public void GetValue()
        {
            Console.WriteLine("Obsolute attribute");
        }


        public void GetValue2()
        {
            Console.WriteLine("Obsolute attribute");
        }

        //генерирует ошибку и не даст собрать проэкт    
        [Obsolete("этот метод устаревший, лучше использовать GetValue2", true)]
        public void GetValue3()
        {
            Console.WriteLine("Obsolute attribute");
        }
    }


    #endregion

    #region одиночные лямбда - выражения

    internal delegate int Incr(int v);

    internal delegate bool IsEven(int v);

    #endregion

    #region блочные лямбда - выражения

    internal delegate int IntOp(int end);

    #endregion


    class Program
    {
        private static DateTime _time = DateTime.Now;


        static void Main(string[] args)
        {

            #region Attributes

            Type t = typeof(UseAttr);
            Console.WriteLine("Атрибуты в классе " + t.Name);


            //true - выведет все атрибута, включая и те, которые применены к базовым склассам
            object[] attribs = t.GetCustomAttributes(true);
            foreach (var obj in attribs)
            {
                Console.WriteLine(obj);

            }

            //Проверяет, содержит ли UseAttr  атрибут RemarkAttribute
            Type tRemerkAttr = typeof(RemarkAttribute);

            //метод выполняется быстро, так как не создает экземпляры атрибутного класса
            //если необходимо установить сам факт приминения атрибута, использовать этот метод
            if (t.IsDefined(tRemerkAttr, false))
            {
                Console.WriteLine("Is defined");
            }

            RemarkAttribute ra = (RemarkAttribute)Attribute.GetCustomAttribute(t, tRemerkAttr);
            if (ra != null)
            {
                Console.WriteLine("Примечание: " + ra.Remark);
                Console.WriteLine("Дополнение: " + ra.Supplement);
                Console.WriteLine("Приоритет: " + ra.Priority);
            }

            TestAttribute test = (TestAttribute)Attribute.GetCustomAttribute(t, typeof(TestAttribute));
            if (test == null)
                Console.WriteLine("doesn`t have TestAttribute");

            Console.WriteLine("*****************************************\n\n");

            Test testConditional = new Test();
            testConditional.Trial();
            testConditional.Release();

            Console.WriteLine("*****************************************\n\n");
            TestObsoluteAttribute testObsoluteAttribute = new TestObsoluteAttribute();
            testObsoluteAttribute.GetValue();
            //генерирует ошибку и не даст собрать проэкт
            //testObsoluteAttribute.GetValue3();

            #endregion

            #region Delegates

            Console.WriteLine("*************** DELEGATE********************/n/n/n");

            StringOps so = new StringOps(); //создает экземпляр объекта


            //Инициализирует делегат
            StrMod strOp = so.RemoveSpaces;
            string str = null;

            //вызывать метод с помощью делегатов
            str = strOp("afasfsdf");


            //Static methods
            Console.WriteLine("Static delegate");
            string delStaticString = "ewfwef fwe  wegewg ----";
            StrModStatic statDel = null;

            statDel += StringOpsStatic.RemoveSpaces;
            statDel += StringOpsStatic.ReplaceSpaces;

            statDel(ref delStaticString);
            Console.WriteLine(delStaticString);


            #endregion



            Anonym();

            Lamda();

            BlockLamda();
        }

        static void Anonym()
        {
            #region Anonymethods

            Console.WriteLine("*************** Anonymethods********************/n/n/n");
            //Анонимный метод без параметров

            CountIt count = delegate
            {
                for (int i = 0; i < 5; i++)
                {
                    Console.WriteLine(i);
                }
                Console.WriteLine();
            };

            count();

            //Анонимный метод c параметрами
            CountItWithParameter countWith = delegate(int end)
            {
                for (int i = 0; i < end; i++)
                {
                    Console.WriteLine(i);

                }
                Console.WriteLine();
            };

            countWith(3);


            //Анонимный метод c параметрами и возвращаемым значением

            CountItWithParameterAndReturnValue countWithAndReturn = delegate(int end)
            {
                int sum = 0;

                for (int i = 0; i < end; i++)
                {
                    sum += i;
                }
                return sum;
            };

            int result = countWithAndReturn(3);
            Console.WriteLine("Result: " + result);

            #endregion
        }

        static void Lamda()
        {
            //одиночные лямбда выражения
            #region lamda expressions

            Console.WriteLine("*************** Lamda expression********************/n/n/n");
            // Создать делегат Incr, ссылающийся на лямбда-выражение.
            // увеличивающее свой параметр на 2.

            Incr incr = count => count + 2;

            //Как  видите,  count  теперь  явно  объявлен  как  параметр  типа  int.  Обратите  также
            //внимание  на  использование  скобок.  Теперь они необходимы.  (Скобки могут быть опу­
            //щены  только  в  том  случае,  если  задается  лишь  один  параметр,  а  его  тип  явно  не  ука­
            //зывается.)
            Incr incr2 = (int count) => count + 2;

            Console.WriteLine("Использование лямбда-выражения Incr: ");

            int x = -10;

            while (x <= 0)
            {
                Console.Write(x + " ");
                x = incr(x);
            }

            Console.WriteLine(Environment.NewLine);

            IsEven isEven = z => z % 2 == 0;

            Console.WriteLine("Использование лямбда-выражения IsEven: ");

            for (int i = 1; i < 10; i++)
            {
                if (isEven(i))
                {
                    Console.WriteLine(i + "четное");
                }
            }
            #endregion
        }

        static void BlockLamda()
        {
            //блочные лямбда выражения
            Console.WriteLine("*************** Lamda-block expression********************/n/n/n");
            IntOp fact = n =>
            {
                int r = 1;
                for (int i = 1; i <= n; i++)
                {
                    r = r * i;
                }
                return r;
            };

            Console.WriteLine("Факториал 3 равен " + fact(3));
        }
    }

    [Remark("Test attribute", Supplement = "Это дополнительная информация", Priority = 10)]
    internal class UseAttr
    {
        public int GetSomething { get; set; }
    }

    [AttributeUsage(AttributeTargets.All)]
    public class RemarkAttribute : Attribute
    {
        private string pri_remark;

        //это поле можно использовать в качестве именованного параметра
        //могут быть открытыя поля и свойства
        public string Supplement;

        public RemarkAttribute(string comment)
        {
            pri_remark = comment;
            Supplement = "Отсутствует";
        }

        public string Remark
        {
            get { return pri_remark; }
        }


        public int Priority { get; set; }
    }

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.ReturnValue, AllowMultiple = true, Inherited = false)]
    public class TestAttribute : Attribute
    {

    }
}
