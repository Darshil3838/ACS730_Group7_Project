terraform {
  backend "s3" {
    bucket = "dev-group7"
    key    = "dev-network/terraform.tfstate"
    region = "us-east-1"
  }
}
