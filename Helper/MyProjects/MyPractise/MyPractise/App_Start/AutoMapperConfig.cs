#region namespaces

using AutoMapper;
using MyPractise.Entities.AutoMapper.Profiles;

#endregion

namespace MyPractise
{
    public class AutoMapperConfig
    {
        public static void Configure()
        {
            Mapper.Initialize(z => z.AddProfile<ExampleProfile>());
        }
    }
}