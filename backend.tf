terraform {
  backend "s3" {
    bucket = "web-infra-tf-state"
    region = "us-east-1"
  }
}