provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source        = "../../modules/vpc"
  cidr_vpc      = "10.0.0.0/16"
  cidr_public1a  = "10.0.1.0/24"
  cidr_public1c = "10.0.2.0/24"
  cidr_private1a = "10.0.11.0/24"
  cidr_private1c = "10.0.21.0/24"
  az1           = "ap-northeast-1a"
  az2           = "ap-northeast-1c"
  env           = var.environment
  service_name  = var.service_name
}

module "ec2" {
  source       = "../../modules/ec2"
  env          = var.environment
  service_name = var.service_name
  public_1a   = module.vpc.public_1a
  vpc_main     = module.vpc.vpc
}

module "ecs" {
  source       = "../../modules/ecs"
  env          = var.environment
  service_name = var.service_name
  vpc_main     = module.vpc.vpc
}

module "route53" {
  source       = "../../modules/route53"
  env          = var.environment
  service_name = var.service_name
  cert = module.acm.cert
}

module "acm" {
  source       = "../../modules/acm"
  env          = var.environment
  service_name = var.service_name
}

module "ecr" {
  source       = "../../modules/ecr"
  env          = var.environment
  service_name = var.service_name
}

module "apprunner" {
  source       = "../../modules/apprunner"
  env          = var.environment
  service_name = var.service_name
  branch = "main"
  domain_name = "botapeer.com"
}

module "alb" {
  source       = "../../modules/alb"
  env          = var.environment
  service_name = var.service_name
  vpc_main     = module.vpc.vpc
  public_1a = module.vpc.public_1a
  public_1c = module.vpc.public_1c
}

