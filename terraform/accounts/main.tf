module "vpc" {
  source = "../modules/vpc"
  enable_nat_gateway = false
}
