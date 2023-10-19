module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }


  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = local.name}
  manage_default_route_table    = true
  default_route_table_tags      = { Name = local.name}
  manage_default_security_group = true
  default_security_group_tags   = { Name = local.name}

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}