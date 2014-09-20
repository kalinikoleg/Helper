#region

using AutoMapper;
using MyPractise.Entities.AutoMapper.Formatters;

#endregion

namespace MyPractise.Entities.AutoMapper.Profiles
{

    public class ExampleProfile : Profile
    {
        protected override void Configure()
        {
            ForSourceType<Name>().AddFormatter<NameFormatter>();
            ForSourceType<decimal>().AddFormatExpression(context =>
                ((decimal)context.SourceValue).ToString("c"));

            //.ForMember(x => x.ShippingAddress, opt =>
            //{
            //  opt.AddFormatter<AddressFormatter>();
            //});
        }
    }
}
