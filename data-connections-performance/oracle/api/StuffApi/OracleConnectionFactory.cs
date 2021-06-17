using Microsoft.Extensions.Options;
using Oracle.ManagedDataAccess.Client;
using System;

namespace StuffApi
{
    public sealed class OracleConnectionFactory : IOracleConnectionFactory
    {
        private readonly IOptions<OracleConfiguration> oracleConfigurationOptions;

        public OracleConnectionFactory(IOptions<OracleConfiguration> oracleConfigurationOptions)
        {
            this.oracleConfigurationOptions = oracleConfigurationOptions;
        }

        public OracleConnection GetConnection()
        {
            OracleConnection sqlconn = null;
            try
            {
                var oracleConfiguration = oracleConfigurationOptions.Value;

                var connectionString = new OracleConnectionStringBuilder(oracleConfiguration.PartialConnectionString)
                {
                    UserID = oracleConfiguration.UserName,
                    Password = oracleConfiguration.Password,
                    ValidateConnection = true
                };

                sqlconn = new OracleConnection(connectionString.ConnectionString);
            }
            catch (Exception ex)
            {
                string str = ex.Message;
            }
            return sqlconn;
        }
    }
}
