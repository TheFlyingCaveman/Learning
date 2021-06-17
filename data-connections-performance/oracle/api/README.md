Configure User Secrets with the following block (if using the included Oracle docker image):

```json
{
  "OracleConnection": {
    "PartialConnectionString": "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=49161)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=xe)))",
    "Username": "system",
    "Password": "oracle"
  }
}
```