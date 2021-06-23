using Newtonsoft.Json;
using NLog;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.ServiceModel.Web;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Xml;
using System.Xml.Linq;

namespace ShopBridgeService.Controllers
{
    public class CreateItemsController : ApiController
    {
        public string Post([FromBody]XElement Input)
        {
            string Output="";

            Output = Helper.ProcessData(Input, "CreateItem") ;

            return Output;

        }
    }
}
