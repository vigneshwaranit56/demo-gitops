module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}

module "jenkins" {
  source     = "./modules/jenkins"
  subnet_id  = module.vpc.public_subnets[0]
  vpc_id     = module.vpc.vpc_id
}