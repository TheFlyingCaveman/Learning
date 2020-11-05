terraform {
  backend "remote" {
    organization = "aws-trfc"

    workspaces {
      name = "code-deploy-tests"
    }
  }
}
