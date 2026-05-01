// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

locals {
  create_kms_key = var.kms_key_arn == null

  default_tags = merge({
    "example" = "complete"
  }, var.tags)

  effective_key_name    = var.key_name == null ? null : trimspace(var.key_name) != "" ? trimspace(var.key_name) : null
  effective_kms_key_arn = coalesce(var.kms_key_arn, try(aws_kms_key.this[0].arn, null))
  primary_subnet_id     = var.create_eip ? module.network.public_subnets[0] : module.network.private_subnets[0]
  replica_subnet_id     = var.create_eip ? module.network.public_subnets[1] : module.network.private_subnets[1]
}

resource "aws_kms_key" "this" {
  count = local.create_kms_key ? 1 : 0

  deletion_window_in_days = 30
  description             = "GHES complete example shared encryption key"
  enable_key_rotation     = true
  tags                    = local.default_tags
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  azs                                             = var.azs
  cidr                                            = var.cidr
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_flow_log                                 = var.enable_flow_log
  enable_ipv6                                     = false
  enable_nat_gateway                              = var.enable_nat_gateway
  flow_log_cloudwatch_log_group_kms_key_id        = local.effective_kms_key_arn
  flow_log_cloudwatch_log_group_retention_in_days = var.log_retention_in_days
  flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_traffic_type                           = var.flow_log_traffic_type
  name                                            = format("%s-network", var.name)
  private_subnet_tags                             = merge(local.default_tags, { "subnet-type" = "private" })
  private_subnets                                 = [for k, v in var.azs : cidrsubnet(var.cidr, 8, k + 20)]
  public_subnet_tags                              = merge(local.default_tags, { "subnet-type" = "public" })
  public_subnets                                  = [for k, v in var.azs : cidrsubnet(var.cidr, 8, k + 10)]
  single_nat_gateway                              = false
  tags                                            = local.default_tags
}

resource "aws_security_group" "primary" {
  description = "Security group for the GHES complete example appliances"
  name        = format("%s-ghes", var.name)
  tags        = local.default_tags
  vpc_id      = module.network.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "primary_ssh" {
  cidr_ipv4         = var.cidr
  from_port         = 22
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.primary.id
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "primary_http" {
  cidr_ipv4         = var.cidr
  from_port         = 80
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.primary.id
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "primary_https" {
  cidr_ipv4         = var.cidr
  from_port         = 443
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.primary.id
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "primary_appliance" {
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.primary.id
  security_group_id            = aws_security_group.primary.id
}

resource "aws_vpc_security_group_egress_rule" "primary_all" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.primary.id
}

module "ghes_primary" {
  source = "../.."

  ami_id                  = var.appliance_ami_id
  create_eip              = var.create_eip
  data_volume_device_name = var.data_volume_device_name
  data_volume_iops        = var.data_volume_iops
  data_volume_size        = var.data_volume_size
  data_volume_throughput  = var.data_volume_throughput
  data_volume_type        = var.data_volume_type
  ebs_optimized           = var.ebs_optimized
  instance_profile_name   = var.instance_profile_name
  instance_type           = var.instance_type
  key_name                = local.effective_key_name
  kms_key_arn             = local.effective_kms_key_arn
  root_volume_iops        = var.root_volume_iops
  root_volume_size        = var.root_volume_size
  root_volume_throughput  = var.root_volume_throughput
  root_volume_type        = var.root_volume_type
  subnet_id               = local.primary_subnet_id
  vpc_security_group_ids  = [aws_security_group.primary.id]

  tags = merge(local.default_tags, {
    "Name"               = format("%s-primary", var.name)
    "ghes:topology-role" = "primary"
  })
}

module "ghes_replica" {
  source = "../.."

  ami_id                  = var.appliance_ami_id
  create_eip              = var.create_eip
  data_volume_device_name = var.data_volume_device_name
  data_volume_iops        = var.data_volume_iops
  data_volume_size        = var.data_volume_size
  data_volume_throughput  = var.data_volume_throughput
  data_volume_type        = var.data_volume_type
  ebs_optimized           = var.ebs_optimized
  instance_profile_name   = var.instance_profile_name
  instance_type           = var.instance_type
  key_name                = local.effective_key_name
  kms_key_arn             = local.effective_kms_key_arn
  root_volume_iops        = var.root_volume_iops
  root_volume_size        = var.root_volume_size
  root_volume_throughput  = var.root_volume_throughput
  root_volume_type        = var.root_volume_type
  subnet_id               = local.replica_subnet_id
  vpc_security_group_ids  = [aws_security_group.primary.id]

  tags = merge(local.default_tags, {
    "Name"               = format("%s-replica", var.name)
    "ghes:topology-role" = "replica"
  })
}
