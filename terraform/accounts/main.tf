module "vpc" {
  source = "../modules/vpc"
  enable_nat_gateway = false
}

# module "eks_cluster" {
#   source = "../modules/eks"
  
#   cluster_name           = "ai-model-cluster"
#   kubernetes_version     = "1.30"
#   vpc_id                 = module.vpc.vpc_id
#   subnet_ids             = module.vpc.private_subnet_ids
  
#   node_group_name        = "ai-model-nodes"
#   desired_size           = 1
#   max_size              = 2
#   min_size              = 1
#   instance_type         = "t3.medium"
#   depends_on = [ module.vpc ]
# }