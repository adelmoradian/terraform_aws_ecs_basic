provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  env    = var.env
  Subnet = var.Subnet
}

module "ec2" {
  source               = "./modules/ec2"
  env                  = var.env
  image_id             = var.image_id
  key_name             = var.key_name
  sg_ids               = module.vpc.sg_ids
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  subnet_ids           = module.vpc.subnet_ids
}
