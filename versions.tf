terraform {
  required_version = ">= 1.0.5"
  required_providers {
    aws = {
      version = ">= 4.19.0"
      source  = "hashicorp/aws"
    }
  }
}
