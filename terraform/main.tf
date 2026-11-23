terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-sofia-lab78"
    key            = "minishop-catalog/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_ecr_repository" "catalog_repo" {
  name                 = "minishop-catalog-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lightsail_container_service" "catalog_service" {
  name        = "minishop-catalog-service"
  power       = "nano"
  scale       = 1
  is_disabled = false
}
