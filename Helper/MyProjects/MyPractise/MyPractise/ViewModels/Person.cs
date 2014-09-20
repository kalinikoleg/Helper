#region

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using MyPractise.Infrastructure.En;

#endregion

namespace MyPractise.ViewModels
{
    public class Person
    {
        public int Id { get; set; }

        [Required(ErrorMessageResourceName = "PersonName", ErrorMessageResourceType = typeof(RequiredMessages))]
        [Display(Name = "PersonName", ResourceType = typeof(Labels))]
        public string Name { get; set; }

        [Required(ErrorMessageResourceName = "Country", ErrorMessageResourceType = typeof(RequiredMessages))]
        [Display(Name = "PersonName", ResourceType = typeof(Labels))]
        public string Country { get; set; }
    }
}