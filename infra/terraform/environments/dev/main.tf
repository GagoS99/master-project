module "iam" {
  source = "./modules/iam"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_id
  instance_profile_name = module.iam.instance_profile_name
}

output "elastic_ip" {
  value = module.ec2.elastic_ip
}
