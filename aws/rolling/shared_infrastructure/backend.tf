terraform {
  backend "remote" {
    organization = "aws-trfc"

    workspaces {
      name = "rolling-shared"
    }
  }
}
