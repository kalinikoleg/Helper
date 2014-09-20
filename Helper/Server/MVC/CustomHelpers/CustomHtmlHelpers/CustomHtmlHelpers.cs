using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PartilalView
{
    public static class CustomHtmlHelpers
    {
        public static MvcHtmlString Submit(this HtmlHelper html, string buttonText = "Send Data", object htmlAttributes = null)
        {
            TagBuilder tag = new TagBuilder("input");
            tag.MergeAttribute("type", "submit");
            tag.MergeAttribute("value", buttonText);
            foreach (PropertyDescriptor descriptor in TypeDescriptor.GetProperties(htmlAttributes))
            {
                object obj = descriptor.GetValue(htmlAttributes);
                tag.MergeAttribute(descriptor.Name, obj.ToString());
            }

            return new MvcHtmlString(tag.ToString(TagRenderMode.SelfClosing));
            //TagRenderMode.SelfClosing генерирует самозакрывающий input />
        }

    }



    //////////////////////dropdownlist/dropdownlistFor

    public static class MyHelpers
    {
        public class MySelectItem : SelectListItem
        {
            public string Class { get; set; }
            public string Disabled { get; set; }
        }

        public static MvcHtmlString MyDropdownListFor<TModel, TProperty>(this HtmlHelper<TModel> htmlHelper, Expression<Func<TModel, TProperty>> expression, IEnumerable<MySelectItem> list, string optionLabel, object htmlAttributes)
        {
            return MyDropdownList(htmlHelper, ExpressionHelper.GetExpressionText(expression), list, optionLabel, HtmlHelper.AnonymousObjectToHtmlAttributes(htmlAttributes));
        }

        public static MvcHtmlString MyDropdownList(this HtmlHelper htmlHelper, string name, IEnumerable<MySelectItem> list, string optionLabel, IDictionary<string, object> htmlAttributes)
        {
            TagBuilder dropdown = new TagBuilder("select");
            dropdown.Attributes.Add("name", name);
            dropdown.Attributes.Add("id", name);
            StringBuilder options = new StringBuilder();

            // Make optionLabel the first item that gets rendered.
            if (optionLabel != null)
                options = options.Append("<option value='" + String.Empty + "'>" + optionLabel + "</option>");

            foreach (var item in list)
            {
                if (item.Disabled == "disabled")
                    options = options.Append("<option value='" + item.Value + "' class='" + item.Class + "' disabled='" + item.Disabled + "'>" + item.Text + "</option>");
                else
                    options = options.Append("<option value='" + item.Value + "' class='" + item.Class + "'>" + item.Text + "</option>");
            }
            dropdown.InnerHtml = options.ToString();
            dropdown.MergeAttributes(new RouteValueDictionary(htmlAttributes));
            return MvcHtmlString.Create(dropdown.ToString(TagRenderMode.Normal));
        }
    }

}
