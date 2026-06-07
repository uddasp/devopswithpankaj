terraform {
  backend "s3" {
    bucket         = "devopswithpankaj-tfstate"
    key            = "devopswithpankaj/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}