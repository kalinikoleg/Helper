//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Infrastructure.Data.DbContext
{
    using System;
    
    public partial class GetDeviceInfoByPurchaseId_Result
    {
        public long Id { get; set; }
        public string Barcode { get; set; }
        public string Manufacturer { get; set; }
        public bool SimCardPresent { get; set; }
        public bool SdCard { get; set; }
        public string ModelName { get; set; }
        public string Imei { get; set; }
        public string Meid { get; set; }
        public string SerialNumber { get; set; }
        public string AdditionalInfo { get; set; }
    }
}
