locals {
  # This creates a nested list, then flattens it into one single list
  # Result: ["product-us-east-1a", "product-us-east-1b", "operations-us-east-1a", "operations-us-east-1b"]
  dynamic_subnet_names = flatten([
    for team in var.teams : [
      for az in var.vpc_azs : "${team}-${az}"
    ]
  ])
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs  = var.vpc_azs

  # 8 Private Subnets (4 depts * 2 AZs)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  private_subnet_names = local.dynamic_subnet_names


  enable_nat_gateway = true
  single_nat_gateway = true

  # This applies these tags to ALL private subnets
  # To make them unique, we often use the 'index' approach or 
  # logical naming in the 'Name' tag via module variables.
  private_subnet_tags = {
    "Layer" = "private"
    "Environment" = var.label_private_subnet_tag_env
  }

  tags = {
    ManagedBy = "Terraform"
  }
}