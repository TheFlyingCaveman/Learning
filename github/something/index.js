const dotenv = require("dotenv");
dotenv.config();
const { createAppAuth } = require("@octokit/auth-app"); // use oauth app
const { request } = require("@octokit/request");

const {readFileSync} = require("fs");

async function main() {
    var contributionsQuery = readFileSync("./graphql/contributionsQuery.graphql", {encoding:'utf8', flag:'r'})

    const requestWithAuth = request.defaults({
        // request: {
        //     hook: auth.hook      
        // },
        headers: {
            authorization: "token " + process.env.TOKEN
        },
        // baseUrl: ""
    });

    const result = await requestWithAuth("POST /graphql", {
        query: contributionsQuery,
        variables: {
            "login": "JoshuaTheMiller",
            "contributionsFrom": "2020-01-01T00:00:00Z"
        }
    });

    console.log(JSON.stringify(result, null, " "));
}

main().catch(console.log);