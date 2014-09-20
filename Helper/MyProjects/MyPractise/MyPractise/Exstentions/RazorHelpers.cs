#region

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web.Configuration;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using Microsoft.Ajax.Utilities;

#endregion

namespace MyPractise.Exstentions
{
    public static class RazorHelpers
    {
        private static readonly string _btnClass = "btn btn-default";
        private static readonly string _btnType = "button";
        private static readonly string _class = "class";

        public static MvcHtmlString MenuLinkBootstrap(this HtmlHelper helper, string text, string action, string controller, string parameter = "")
        {
            var routeData = helper.ViewContext.RouteData.Values;

            var currentController = routeData["controller"];
            var currentAction = routeData["action"];
            if (String.Equals(action, currentAction as string, StringComparison.OrdinalIgnoreCase) &&
              String.Equals(controller, currentController as string, StringComparison.OrdinalIgnoreCase))
            {
                return new MvcHtmlString("<li class=\"active\">" + helper.ActionLink(text, action, controller, new { id = parameter }, null) + "</li>");
            }
            return new MvcHtmlString("<li>" + helper.ActionLink(text, action, controller, new { id = parameter }, null) + "</li>");
        }


        /// <summary>
        /// Кнопки без изменения ширины
        /// метод добавляет в классы к существуюющему, но не перезаписует
        /// </summary>
        /// <param name="html">Current Html object in View</param>
        /// <param name="text">Value of button</param>
        /// <param name="htmlAttrsDic">Dictionary of html attributes</param>
        /// <param name="useDefaultClasses">should use default classes</param>
        /// <returns>Html button</returns>
        public static MvcHtmlString Button(this HtmlHelper html, IDictionary<string, string> htmlAttrsDic,
            string text = "Send Data", bool useDefaultClasses = true)
        {

            TagBuilder tag = new TagBuilder("input");

            IDictionary<string, string> attributes = new Dictionary<string, string>()
                {
                    {"type", _btnType},
                    {"value", text}
                };

            if (useDefaultClasses)
            {
                attributes.Add(_class, _btnClass);

                var res = htmlAttrsDic.SingleOrDefault(z => z.Key == _class);
                if (res.Key != null)
                {
                    attributes[res.Key] += " " + res.Value;
                    htmlAttrsDic.Remove(res.Key);
                }
            }

            attributes = attributes
                .Union(htmlAttrsDic)
                .ToDictionary(z => z.Key, v => v.Value);

            tag.MergeAttributes(attributes);

            return new MvcHtmlString(tag.ToString(TagRenderMode.SelfClosing));
        }

        /// <summary>
        /// Кнопки без изменения ширины
        /// добавляет классы к существующему, но не перезаписует
        /// </summary>
        /// <param name="html"></param>
        /// <param name="htmlAttrs"></param>
        /// <param name="text"></param>
        /// <param name="useDefaultClasses">should use default classes</param>
        /// <returns></returns>
        public static MvcHtmlString Button(this HtmlHelper html, object htmlAttrs = null, string text = "Send Data",
                bool useDefaultClasses = true)
        {
            TagBuilder tag = new TagBuilder("input");

            tag.MergeAttribute("type", _btnType);
            tag.MergeAttribute("value", text);
            if (useDefaultClasses)
            {
                tag.MergeAttribute(_class, _btnClass);
            }
            foreach (PropertyDescriptor descriptor in TypeDescriptor.GetProperties(htmlAttrs))
            {
                object obj = descriptor.GetValue(htmlAttrs);
                if (useDefaultClasses && descriptor.Name == _class)
                {
                    obj += " " + obj;
                }
                tag.MergeAttribute(descriptor.Name, obj.ToString());
            }

            return new MvcHtmlString(tag.ToString(TagRenderMode.SelfClosing));
        }
    }
}