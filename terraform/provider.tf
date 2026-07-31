provider "aws" {

  region = var.aws_region

}

terraform {

  required_version = ">=1.6"

  backend "s3" {

    bucket = "funschoolapi-terraform-state-846511227413"

    key = "dev/terraform.tfstate"

    region = "ap-south-1"

    dynamodb_table = "terraform-lock"

    encrypt = true

  }
}