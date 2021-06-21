using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic;
using System.ServiceModel.Channels;
using System.ServiceModel.Web;

// Namespace eShopaidRestService
namespace ShopBridgeService
{
    [Serializable]
    public class RawContentTypeMapper : WebContentTypeMapper
    {
        public override WebContentFormat GetMessageFormatForContentType(string contentType)
        {
            if (contentType.Contains("application/xml") || contentType.Contains("application/json"))
                return WebContentFormat.Raw;
            else
                return WebContentFormat.Default;
        }
    }
    // End Namespace
}