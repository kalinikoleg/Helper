#region NameSpaces
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Resources;
using System.Web.Mvc;
using PhoneIdWebApp.Attributes;

#endregion

namespace PhoneIdWebApp.Extensions
{
    public static class EnumHelper
    {
        public static IList<SelectListItem> GetSelectListItems<T>(Type recource, string defaultSelectedFieldName, params T[] list)
        {
            IList<SelectListItem> result = new List<SelectListItem>();

            ResourceManager rm = null;

            if (recource != null)
            {
                rm = new ResourceManager(recource.FullName, recource.Assembly);
            }

            foreach (var item in list)
            {
                FieldInfo[] fields = item.GetType().GetFields();
                foreach (var field in fields)
                {
                    if (field.Name.Equals("value__")) continue;
                    if (field.Name.Equals(item.ToString()))
                    {
                        result.Add(new SelectListItem()
                        {
                            Text = rm == null ? field.Name : rm.GetString(field.Name),
                            Value = Convert.ToString(field.GetRawConstantValue())
                        });
                    }
                }
            }

            result.Insert(0, new SelectListItem()
            {
                Selected = true,
                Value = null,
                Text = rm == null ? defaultSelectedFieldName : rm.GetString(defaultSelectedFieldName)
            });
            return result;
        }

    }
}