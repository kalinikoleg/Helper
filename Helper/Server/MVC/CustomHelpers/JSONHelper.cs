using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DeclarationPortal.Web.Ui.Helpers
{
    public class JSONHelper
    {
        public static string Serialize<T>(T obj)
        {
            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string retVal = serializer.Serialize(obj);
            return retVal;
        }

        public static T Deserialize<T>(string json)
        {
            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            T retVal = serializer.Deserialize<T>(json);
            return retVal;
        }
    }
}



////////
@Html.Raw(new System.Web.Script.Serialization.JavaScriptSerializer()
.Serialize(productModels.Select(z=>new {modelName = z.ModelName, engineType =  z.EngineType})));

System.Web.Helpers.Json.Encode(list);


////JSONConvert
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;


1. public static string ConvertToJson<T>(T obj)
        {
            return JsonConvert.SerializeObject(obj, Formatting.Indented, new JsonSerializerSettings()
            {
                //ставит в нижний регистр только первый символ
                ContractResolver = new CamelCasePropertyNamesContractResolver()
            });
            
        }


2. JsonSerializerSettings settings = new JsonSerializerSettings
            {
                ContractResolver = new LowercaseContractResolver() //ставит в нижний регистр всю строку
            };
  var json = JsonConvert.SerializeObject(user, Formatting.Indented, Common.settings);
 public class LowercaseContractResolver : DefaultContractResolver
    {
        protected override string ResolvePropertyName(string propertyName)
        {
            return propertyName.ToLower();
        }
    }