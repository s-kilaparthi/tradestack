terraform {
  backend "s3" {
    bucket  = "tradestack-terraform-state-169588426254"
    key     = "dev/terraform.tfstate"
    region  = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
