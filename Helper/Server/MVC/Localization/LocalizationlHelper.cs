using System.Globalization;
using System.Web;
using System.Web.Compilation;
using System.Web.Mvc;
using System;

namespace eComSite.Helpers
{
    public static class LocalizationHelpers
    {
        /// <summary>
        /// Load resource string
        /// </summary>
        /// <param name="htmlhelper">html helper object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="args">string arguments</param>
        /// <returns>result resource string</returns>
        public static string Resource(this HtmlHelper htmlhelper, 
            string expression, 
            params object[] args)
        {
            string virtualPath = GetVirtualPath(htmlhelper);

            return GetResourceString(htmlhelper.ViewContext.HttpContext, 
                expression, virtualPath, args);
        }

        /// <summary>
        /// Load resource string
        /// </summary>
        /// <param name="controller">controller object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="args">string arguments</param>
        /// <returns>result resource string</returns>
        public static string Resource(this Controller controller, 
            string expression, 
            params object[] args)
        {
            return GetResourceString(controller.HttpContext, expression, "~/", args);
        }

        /// <summary>
        /// Load resource string for control (partial view)
        /// </summary>
        /// <param name="htmlHelper">html helper object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="virtualPath">virtual path string</param>
        /// <param name="args">string arguments</param>
        /// <returns>result resource string</returns>
        public static string ResourceCtrl(this HtmlHelper htmlHelper, string expression,
            string virtualPath,
            params object[] args)
        {
            return GetResourceString(htmlHelper.ViewContext.HttpContext,
                expression, virtualPath, args);
        }

        /// <summary>
        /// Load resource string which is JavaScript safe string
        /// </summary>
        /// <param name="htmlHelper">helper object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="virtualPath">virtual path of control</param>
        /// <param name="args">string argument</param>
        /// <returns></returns>
        public static string ResourceScriptSafe(this HtmlHelper htmlHelper, 
            string expression,
            string virtualPath,
            params object[] args)
        {
            return ToScriptSafeString(GetResourceString(htmlHelper.ViewContext.HttpContext,
                              expression, virtualPath, args));
        }

        /// <summary>
        /// Load resource string which is JavaScript safe string
        /// </summary>
        /// <param name="htmlhelper">helper object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="args">string arguments</param>
        /// <returns></returns>
        public static string ResourceScriptSafe(this HtmlHelper htmlhelper,
            string expression,
            params object[] args)
        {
            string virtualPath = GetVirtualPath(htmlhelper);

            return ToScriptSafeString(GetResourceString(htmlhelper.ViewContext.HttpContext,
                expression, virtualPath, args));
        }

        /// <summary>
        /// Load resource string which is JavaScript safe string
        /// </summary>
        /// <param name="controller">controller object</param>
        /// <param name="expression">resource key expression</param>
        /// <param name="args">string arguments</param>
        /// <returns>result resource string</returns>
        public static string ResourceScriptSafe(this Controller controller,
            string expression,
            params object[] args)
        {
            return ToScriptSafeString(GetResourceString(controller.HttpContext, 
                expression, "~/", args));
        }


        private static string GetResourceString(HttpContextBase httpContext, 
            string expression, 
            string virtualPath, 
            object[] args)
        {
            var context = new ExpressionBuilderContext(virtualPath);
            var builder = new ResourceExpressionBuilder();

            try
            {
                var fields = (ResourceExpressionFields) builder.ParseExpression(expression, 
                    typeof (string), 
                    context);

                if (!string.IsNullOrEmpty(fields.ClassKey))
                    return string.Format((string)httpContext.GetGlobalResourceObject(fields.ClassKey, 
                        fields.ResourceKey, CultureInfo.CurrentUICulture), args);

                return
                    string.Format((string)httpContext.GetLocalResourceObject(virtualPath, 
                        fields.ResourceKey, CultureInfo.CurrentUICulture), args);

            }
            catch (HttpException)
            {
                return string.Empty;
            }
        }

        private static string GetVirtualPath(HtmlHelper htmlHelper)
        {
            string virtualPath = null;
            var view = htmlHelper.ViewContext.View as BuildManagerCompiledView;

            if (view != null)
            {
                virtualPath = view.ViewPath;
            }
            return virtualPath;
        }

        private static string ToScriptSafeString(string s)
        {
            if (string.IsNullOrEmpty(s))
            {
                return string.Empty;
            }
            s = s.Replace(@"\", @"\\");
            s = s.Replace("\"", "\\\"");
            s = s.Replace("'", @"\'");
            s = s.Replace("\r", @"\r");
            s = s.Replace("\n", @"\n");
            s = s.Replace("\t", @"\t");
            return s;
        }

        public static string GetResourceByName(string fieldResourceName, string virtualPath)
        {
            string result = string.Empty;

            var context = new ExpressionBuilderContext(virtualPath);
            var builder = new ResourceExpressionBuilder();

            try
            {
                var fields =
                    (ResourceExpressionFields)builder.ParseExpression(fieldResourceName, typeof(string), context);
                result =
                    (string)
                        HttpContext.GetLocalResourceObject(virtualPath, fields.ResourceKey, CultureInfo.CurrentCulture);
            }
            catch (Exception e)
            {
                result = "The field underfined";
            }
            return result;
        }
    }
}