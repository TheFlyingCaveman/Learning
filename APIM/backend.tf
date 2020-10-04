terraform {
  backend "remote" {
    organization = "joshuadmilleroptum"

    workspaces {
      name = "playingwithapim"
    }
  }
}