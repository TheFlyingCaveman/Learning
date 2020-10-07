This folder contains thoughts constructed from playing around with APIM.

Remote state is stored, planned, and applied on Terraform Cloud: [Terraform Workspace](https://app.terraform.io/app/joshuadmilleroptum/workspaces/AzureExperiments)

⚠ Please note that plans are auto applied for speed

I may comment out entire files to test out different concepts and save money. I am going the comment route here, in lieu of full delete, because I still want to easily see past experiments. Yes, I could just look through my commit history, but this is an experimentation repo and it is helpful to see what I've experimented with all at the same time.

## Files

* main.tf --> contains the main APIM resource and resource group
* passthroughandfunction.tf --> contains a passthrough and certain policies playing around with rate limiting, as I am exceptionally paranoid about exposing a Consumption based Function without any sort of front end control. I don't want to induce massive costs due to one of my friends playing around with my API, after all 🙃
* backend.tf, provider.tf, terraform.tfvars, and variables.tf are self explanatory by their names.