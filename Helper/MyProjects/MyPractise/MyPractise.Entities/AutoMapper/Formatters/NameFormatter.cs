#region

using System.Text;
using MyPractise.Entities.AutoMapper.Formatters.Abstract;

#endregion

namespace MyPractise.Entities.AutoMapper.Formatters
{
    public class NameFormatter : ValueFormatter<Name>
    {
        protected override string FormatValueCore(Name value)
        {
            var sb = new StringBuilder();

            if (!string.IsNullOrEmpty(value.First))
            {
                sb.Append(value.First);
            }
            if (!string.IsNullOrEmpty(value.Middle))
            {
                sb.Append(" " + value.Middle);
            }
            if (!string.IsNullOrEmpty(value.Last))
            {
                sb.Append(" " + value.Last);
            }
            if (value.Suffix != null)
            {
                sb.Append(", " + value.Suffix);
            }
            return sb.ToString();
        }
    }
}
