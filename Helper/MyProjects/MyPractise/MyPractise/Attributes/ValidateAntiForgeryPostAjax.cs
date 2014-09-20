#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;

#endregion

namespace MyPractise.Attributes
{
    [AttributeUsage(AttributeTargets.Class|AttributeTargets.Method)]
    public class ValidateAntiForgeryPostAjax : AuthorizeAttribute
    {
        public  override void OnAuthorization(AuthorizationContext filterContext)
        {
            var request = filterContext.HttpContext.Request;
            if (request.HttpMethod == WebRequestMethods.Http.Post)
            {
                //  Ajax POSTs and normal form posts have to be treated differently when it comes
                //  to validating the AntiForgeryToken
                if (request.IsAjaxRequest())
                {
                    var antiForgeryCookie = request.Cookies[AntiForgeryConfig.CookieName];

                    var cookieValue = antiForgeryCookie != null ? antiForgeryCookie.Value : null;
                    AntiForgery.Validate(cookieValue, request.Headers["__RequestVerificationToken"]);
                }
                else
                {
                    new ValidateAntiForgeryTokenAttribute().OnAuthorization(filterContext);
                }
            }
        }  
    }
}

/*
 * JS
  $.ajax({
            type: 'POST',
            contentType: 'application/json; charset=utf-8', //this type will be send to the server
            dataType: 'json', //this type back from the server
            url: "/Ajax/GetUserList",
            data: ko.toJSON(parameters),
            error: function (jqXHR, textStatus, errorThrown) {
                alert(jqXHR.responseText);
            },
            success: function (result) {
                //return in jason format
                var res = result;
            },
            complete: function (XMLHttpRequest, textStatus) {
                //self.loader.HideLoading('mainContent');
            },
            beforeSend: function (xhr) {
                var securityToken = $('[name=__RequestVerificationToken]').val();
                xhr.setRequestHeader('__RequestVerificationToken', securityToken);
                //self.loader.ShowLoading('mainContent');
            }
        });
 
 
 */