using System;
using GoodCode.DataBases;
using GoodCode.Interfaces;
using GoodCode.Models;
using Microsoft.Practices.Unity;

namespace GoodCode.Repositories.MsSqlRepository
{
    public partial class MsSqlRepository : IRepository, IDisposable
    {
        private readonly AuthDBEntities db;

        public MsSqlRepository(AuthDBEntities cont)
        {
            db = cont;
        }
        public AuthDBEntities DbContext
        {
            get { return db; }
        }

        public void Dispose()
        {
            var c = 10;
        }
    }
}
