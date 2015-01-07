using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace LazyInitialization.Pattern
{
    public class DataSource { public DataSource(object obj) { } }
    public class OfficeInfo { public int Id { get; set; }}



    public class LazyOfficeDataManager
    {
        private Dictionary<int, Lazy<DataSource>> _office =
            new Dictionary<int, Lazy<DataSource>>();

        /// <summary>
        /// <see cref="Description.js"/>
        /// </summary>
        public LazyOfficeDataManager()
        {
            OfficeInfo[] _office = this.GetOfficeList();

            foreach (var info in _office)
            {
                // Такой подход используется для корректного захвата переменной цикла внутри анонимной функции инициализации объекта
                OfficeInfo infoForClouser = info;

                Lazy<DataSource> dataSource = new Lazy<DataSource>(() =>
                {
                    return new DataSource(infoForClouser);
                }, LazyThreadSafetyMode.ExecutionAndPublication);
                //благодаря режиму ExecutionAndPublication, создание объекта гарантировано 
                //потокобезопасное и будет происходить только один раз.

                this._office.Add(infoForClouser.Id, dataSource);
            }
        }

        public DataSource Get(int index)
        {
            return _office[1].Value;
        }

        public OfficeInfo[] GetOfficeList()
        {
            return new OfficeInfo[2];
        }
    }
}
