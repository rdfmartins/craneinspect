module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "ec2" {
  source = "./modules/ec2"

  project_name  = var.project_name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  instance_type = "t3.micro"
}

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = "dev"
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
  db_password           = var.db_password
}
