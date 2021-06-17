namespace StuffApi
{
    public sealed class OracleConfiguration
    {
        internal static readonly string SectionName = "OracleConnection";

        public string UserName { get; set; }
        public string Password { get; set; }
        public string PartialConnectionString { get; set; }
    }
}