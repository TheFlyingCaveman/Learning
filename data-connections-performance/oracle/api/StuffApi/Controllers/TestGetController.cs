using Microsoft.AspNetCore.Mvc;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;

namespace StuffApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public sealed class TestGetController : ControllerBase
    {
        public sealed class Stuff
        {
            public int Id { get; init; }
            public string Description { get; init; }
        }

        private readonly IOracleConnectionFactory oracleConnectionFactory;

        public TestGetController(IOracleConnectionFactory oracleConnectionFactory)
        {
            this.oracleConnectionFactory = oracleConnectionFactory;
        }

        [HttpGet]
        public async Task<IEnumerable<Stuff>> Get()
        {
            var things = await DoDatabaseCall();
            return things;
        }

        private async Task<IEnumerable<Stuff>> DoDatabaseCall()
        {
            var stuffList = new List<Stuff>();

            using (var connection = oracleConnectionFactory.GetConnection())
            using (var command = new OracleCommand("SELECT * FROM sys.stuff", connection))
            {
                command.CommandType = CommandType.Text;

                connection.Open();

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (reader.Read())
                    {
                        stuffList.Add(new Stuff
                        {
                            Id = reader.GetInt32("id"),
                            Description = reader.GetString("description")
                        });
                    }
                }
            }

            return stuffList;
        }
    }
}
