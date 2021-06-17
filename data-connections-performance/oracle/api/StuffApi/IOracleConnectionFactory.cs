using Oracle.ManagedDataAccess.Client;

namespace StuffApi
{
    public interface IOracleConnectionFactory
    {
        OracleConnection GetConnection();
    }
}