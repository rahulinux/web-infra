variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "create_instance" {
  type    = bool
  default = true
}