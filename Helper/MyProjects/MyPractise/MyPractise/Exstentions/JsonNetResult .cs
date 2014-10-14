#region namespaces

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Serialization;

#endregion

namespace MyPractise.Exstentions
{

    public class JsonNetResult : JsonResult
    {

        private static readonly JsonSerializerSettings _settings = new JsonSerializerSettings()
        {
            //ставит в нижний регистр только первый символ
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
                
            //конвертирует enum в названия, а не выдает код перечисления
            Converters = new List<JsonConverter> { new StringEnumConverter() }
        };
        public override void ExecuteResult(ControllerContext context)
        {
            if (this.JsonRequestBehavior == JsonRequestBehavior.DenyGet &&
                string.Equals(context.HttpContext.Request.HttpMethod, "GET", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("GET request not allowed");
            }

            var response = context.HttpContext.Response;
            response.ContentType = !string.IsNullOrEmpty(this.ContentType) ? this.ContentType : "application/json";

            if (this.ContentEncoding != null)
            {
                response.ContentEncoding = this.ContentEncoding;
            }

            if (this.Data == null)
            {
                return;
            }

            response.Write(JsonConvert.SerializeObject(this.Data, _settings));
        }
    }
}