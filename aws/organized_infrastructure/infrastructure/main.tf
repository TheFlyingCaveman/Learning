module "app_one" {
  source = "./modules/application"

  name                = "testapp"
  description         = "This was made for a test"
  environment         = "PoC"
  solution_stack_name = "64bit Amazon Linux 2 v5.2.5 running Node.js 12"
}
