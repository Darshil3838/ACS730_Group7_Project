terraform {
  backend "s3" {
    bucket = "staging-group7-project"
    key    = "staging-network/terraform.tfstate"
    region = "us-east-1"
  }
}
