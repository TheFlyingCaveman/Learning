terraform {
  backend "remote" {
    organization = "aws-trfc"

    workspaces {
      name = "liquibase-sms"
    }
  }
}
