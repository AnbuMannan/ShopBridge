using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Xml.Linq;

namespace ShopBridgeService.Controllers
{
    public class UpdateItemsController : ApiController
    {
        public string Post([FromBody]XElement Input)
        {
            string Output = "";

            Output = Helper.ProcessData(Input, "UpdateItem");

            return Output;

        }
    }
}
