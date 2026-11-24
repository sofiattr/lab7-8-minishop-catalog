terraform {
  required_version = ">=0.13.0"
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

variable "lightsail_image" {
  description = "Повна назва завантаженого образу у Lightsail"
  type        = string
  default     = ""
}

resource "aws_ecr_repository" "catalog_repo" {
  name                 = "minishop-catalog-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_lightsail_container_service" "catalog_service" {
  name  = "minishop-catalog-service"
  power = "nano"
  scale = 1
}

# Декларативне розгортання контейнера catalog-app через Terraform
resource "aws_lightsail_container_service_deployment_version" "catalog_deployment" {
  count        = var.lightsail_image != "" ? 1 : 0
  service_name = aws_lightsail_container_service.catalog_service.name

  container {
    container_name = "catalog-app"
    image          = var.lightsail_image

    ports = {
      8001 = "HTTP"
    }
  }

  public_endpoint {
    container_name = "catalog-app"
    container_port = 8001

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/health"
      success_codes       = "200-499"
    }
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.catalog_repo.repository_url
}

output "lightsail_url" {
  value = aws_lightsail_container_service.catalog_service.url
}
