using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace ShopBridgeService
{
    [ServiceContract]
    public interface IShopBridgeService
    {

        [OperationContract(Name = "ProcessData")]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.Bare, UriTemplate = "/ProcessData")]
        Stream ProcessData(Stream InputData);

    }
}
