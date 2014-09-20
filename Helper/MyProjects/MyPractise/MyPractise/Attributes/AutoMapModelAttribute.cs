using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AutoMapper;


namespace MyPractise.Attributes
{

    /*
         Применяя  этот  атрибут  к  методу  действия,  мы  указываем  AutoMapper  преобразовать 
    ViewData.Model.  Этот  атрибут  предоставляет  важную  функциональность  –  ведь  довольно  легко 
    забыть применить пользовательский атрибут, а наши представления не будут работать, если атрибут 
    отсутствует.  Альтернативный  подход  -  вернуть  пользовательский  результат  действия,  который 
    инкапсулирует эту логику, и не использовать фильтр.
     */

    public class AutoMapModelAttribute : ActionFilterAttribute
    {
        private readonly Type _destType;
        private readonly Type _sourceType;

        public AutoMapModelAttribute(Type sourceType, Type destType)
        {
            _sourceType = sourceType;
            _destType = destType;
        }

        public override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            var model = filterContext.Controller.ViewData.Model;
            var viewModel = Mapper.Map(model, _sourceType, _destType);
            filterContext.Controller.ViewData.Model = viewModel;

        }
    }
}