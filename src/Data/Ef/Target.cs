//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HoomanLogic.Data.Ef
{
    using System;
    using System.Collections.Generic;
    
    public partial class Target
    {
        public System.Guid Id { get; set; }
        public string UserId { get; set; }
        public System.Guid TagId { get; set; }
        public string Kind { get; set; }
        public string Timeline { get; set; }
        public short Goal { get; set; }
        public Nullable<System.DateTime> Enlist { get; set; }
        public Nullable<System.DateTime> Retire { get; set; }
    
        public virtual AspNetUser AspNetUser { get; set; }
        public virtual Tag Tag { get; set; }
    }
}
