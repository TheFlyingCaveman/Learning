## Problem

How should one go about deploying changes to an Azure hosted database when that database is **not** accessible via the public internet?

Quick answer: if using a self-hosted build agent (Azure DevOps, GitHub Actions, Circle CI, TeamCity, etc), this is fairly straightforward: place a build agent within the same virtual network as the database. 

If you are not using a self-hosted build agent, this gets somewhat more complicated (and could involve some combination of Azure Functions, Azure Storage, and Azure Container Instances).

It sure would be nice if Azure had a service like AWS Code Deploy... Granted, Azure DevOps Pipelines is basically CodeDeploy on steroids... But it doesn't *feel* as integrated with Azure as CodeDeploy feels with AWS. This last statement is all about perception, which is still important when dealing with enterprise restrictions.