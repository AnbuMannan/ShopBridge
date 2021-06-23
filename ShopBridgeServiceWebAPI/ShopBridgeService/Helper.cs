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

namespace ShopBridgeService
{
    public class Helper
    {
        public static string ProcessData(XElement InputData, string Mode)
        {
            string Result = "", DataFormat = "";
            StreamReader SR;
            object Obj;
            XNode Node = null;
            string InputStr = "";
            XmlNode XMLNode;
            XmlDocument X = new XmlDocument();
            string MethodName;
            string ClientIPAddress;
            SqlConnection AuthCon = null;
            ILogger ServiceLog = null;
            string MethodHandler = "", RequestXML = "";
            ClientIPAddress = HttpContext.Current.Request.UserHostAddress;
            XmlDocument XMLDoc, XMLDOC4Result;

            try
            {
                ServiceLog = LogManager.GetLogger("ShopBridge");

                MethodName = Mode;

                if (MethodName == null)
                    MethodName = "";

                ServiceLog.Info("Request From Client>> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt") + " >> Process Data Started");


                ServiceLog.Info("ConnectionString Verification >> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt"));

                string ConStr = "";

                if (ConfigurationManager.AppSettings["ConnectionString"] != "")
                    ConStr = ConfigurationManager.AppSettings["ConnectionString"];

                if (ConStr == "")
                    throw new ApplicationException("Invalid configuration : Connection string not configured");


                if (ConfigurationManager.AppSettings["DataFormat"] == null)
                    throw new ApplicationException("Invalid configuration ! please configure dataformat in config file");
                if (ConfigurationManager.AppSettings["DataFormat"].ToString() == "")
                    throw new ApplicationException("Invalid configuration !  dataformat cannot be empty in config file");
                if (ConfigurationManager.AppSettings["DataFormat"].ToString() != "JSON" && ConfigurationManager.AppSettings["DataFormat"].ToString() != "XML")
                    throw new ApplicationException("Invalid configuration ! invalid dataformat  in config file");

                DataFormat = ConfigurationManager.AppSettings["DataFormat"].ToString();



                // ============================
                // ===> Getting Connection <===
                // ============================
                try
                {
                    AuthCon = new SqlConnection();
                    AuthCon.ConnectionString = ConStr;
                    AuthCon.Open();

                    ServiceLog.Info("Connection Verified >> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt"));
                }
                catch (Exception ConEx)
                {
                    if (ConEx.InnerException != null)
                    {
                        ServiceLog.Info("Error in Connection>> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt") + ":" + ConEx.InnerException.ToString());
                        return ("Error in Connection :" + ConEx.InnerException.ToString());
                    }
                    else
                    {

                        ServiceLog.Info("Error in Connection>> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt") + ":" + ConEx.Message);
                        return ("Error in Connection :" + ConEx.Message);
                    }
                }

                XMLDoc = new XmlDocument();
                if ((InputData != null))
                {
                    XMLDoc.LoadXml(InputData.ToString());
                    RequestXML = XMLDoc.OuterXml;
                }

                ServiceLog.Info("Process Request Initiated>> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt"));


                if (ConfigurationManager.AppSettings[MethodName] != null && ConfigurationManager.AppSettings[MethodName] != "")
                {
                    MethodHandler = ConfigurationManager.AppSettings[MethodName];
                }

                if (MethodHandler == "")
                {
                    throw new ApplicationException(MethodName + " not configured");
                }

                ServiceLog.Info(("Request>> " + (DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt") + ("; Method: " + MethodName))));

                ServiceLog.Info(("Request XML >> " + RequestXML));

                // Executing Procedure
                XMLDOC4Result = new XmlDocument();

                try
                {
                    SqlCommand Cmd = new SqlCommand();
                    Cmd.Connection = AuthCon;
                    Cmd.CommandType = CommandType.StoredProcedure;
                    Cmd.Parameters.Add(GetParameter(Cmd, "ParamXML", RequestXML, DbType.Xml));
                    Cmd.CommandText = MethodHandler;
                    SqlDataReader DataReader = Cmd.ExecuteReader();
                    while (DataReader.Read())
                    {
                        Result = Convert.ToString(DataReader.GetValue(0));
                    }

                    if (RequestXML != "")
                        Result = "<Response><Result>" + "SUCCESS" + "</Result><StatusMessage>" + Result + "</StatusMessage></Response>";
                    else
                        Result = "<Response><Result>" + "SUCCESS" + "</Result>" + Result + "</Response>";

                    DataReader.Close();


                    XMLDOC4Result.LoadXml(Result);
                }
                catch (SqlException se)
                {
                    Result = "<Response><Result>" + "FAILURE" + "</Result><FailureReason>" + se.Message + "</FailureReason></Response>";
                    XMLDOC4Result.LoadXml(Result);
                }
                catch (Exception e)
                {
                    Result = "<Response><Result>" + "SUCCESS" + "</Result><FailureReason>" + e.Message + "</FailureReason></Response>";
                    XMLDOC4Result.LoadXml(Result);
                }

                ServiceLog.Info("ProcessData_Result:" + Result);
            }
            catch (Exception ex)
            {
                Result = ex.Message.ToString();

                ServiceLog.Info("Result.Error.Message>> " + DateTime.Now.ToString("yyyyMMdd hh:mm:ss:fff tt") + ":" + ex.Message.ToString());
                Result = "<Response><Result>FAILURE</Result><FailureReason>" + Result + "</FailureReason></Response>";
                XmlDocument ErrDoc;
                ErrDoc = new XmlDocument();

                ErrDoc.LoadXml(Result);

                ServiceLog.Info("ProcessData_Result:" + Result);
            }
            finally
            {
                SR = null;
                if (AuthCon != null && AuthCon.State != ConnectionState.Closed)
                    AuthCon.Close();
            }

            return (Result);
        }
        private Stream StreamOP(string input)
        {
            byte[] byteArray = Encoding.ASCII.GetBytes(input);
            MemoryStream stream = new MemoryStream(byteArray);
            return stream;
        }
        private static DbParameter GetParameter(DbCommand Cmd, string ParameterName, object ParameterValue, DbType ParameterType)
        {
            DbParameter Param;
            try
            {
                Param = Cmd.CreateParameter();
                Param.ParameterName = ParameterName;
                Param.DbType = ParameterType;
                Param.Value = ParameterValue;
            }
            catch (Exception Ex)
            {
                throw new ApplicationException(("GetParameter(); " + Ex.Message));
            }

            return Param;
        }

    }
}