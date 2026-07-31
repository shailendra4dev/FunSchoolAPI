terraform {

  required_version = ">= 1.6"

  backend "s3" {}

}

provider "aws" {
  region = var.aws_region
}