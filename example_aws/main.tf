module "network" {
  source             = "./modules/network"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  prefix             = var.prefix
}

module "cluster" {
  source             = "./modules/cluster"
  prefix             = var.prefix
  subnet_ids         = module.network.subnet_ids
  security_group_ids = [module.network.security_group_id]
  instance_count     = var.instance_count
  vpc_id             = module.network.vpc_id
  user_data          = file("user_data.sh")
  desired_capacity   = 2
  min_size           = 1
  max_size           = 3
  scale_in           = var.scale_in
  scale_out          = var.scale_out
}
