terraform {
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "resource_base_name" {
  default = "ppm"
}

module "ppm" {
  resource_base_name = var.resource_base_name
  source = "./modules"
}

