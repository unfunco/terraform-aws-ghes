// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

locals {
  create_eip     = var.create && var.create_eip
  create_kms_key = var.create && var.kms_key_arn == null

  data_volume_iops       = contains(["gp3", "io1", "io2"], var.data_volume_type) ? coalesce(var.data_volume_iops, 3000) : null
  data_volume_throughput = var.data_volume_type == "gp3" ? coalesce(var.data_volume_throughput, 125) : null

  default_tags = merge({
    "terraform-module" = "unfunco/terraform-aws-ghes"
  }, var.tags)

  appliance_ami_id = local.resolved_ami_id
  appliance_public_ip = coalesce(
    try(one(aws_eip.this[*].public_ip), null),
    try(one(aws_instance.this[*].public_ip), null),
  )

  resolved_ami_id        = trimspace(var.ami_id)
  resolved_kms_key_arn   = var.create ? coalesce(one(aws_kms_key.this[*].arn), var.kms_key_arn) : var.kms_key_arn
  root_volume_iops       = contains(["gp3", "io1", "io2"], var.root_volume_type) ? coalesce(var.root_volume_iops, 3000) : null
  root_volume_throughput = var.root_volume_type == "gp3" ? coalesce(var.root_volume_throughput, 125) : null
}

resource "aws_kms_key" "this" {
  count = local.create_kms_key ? 1 : 0

  deletion_window_in_days = 30
  description             = "GHES appliance encryption key"
  enable_key_rotation     = true
  tags                    = local.default_tags
}

resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  ami                         = local.appliance_ami_id
  associate_public_ip_address = var.create_eip
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.instance_profile_name
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = var.subnet_id
  tenancy                     = "default"
  volume_tags                 = local.default_tags
  vpc_security_group_ids      = var.vpc_security_group_ids
  tags                        = local.default_tags

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = local.root_volume_iops
    kms_key_id            = local.resolved_kms_key_arn
    throughput            = local.root_volume_throughput
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = var.data_volume_device_name
    encrypted             = true
    iops                  = local.data_volume_iops
    kms_key_id            = local.resolved_kms_key_arn
    throughput            = local.data_volume_throughput
    volume_size           = var.data_volume_size
    volume_type           = var.data_volume_type
  }
}

resource "aws_eip" "this" {
  count = local.create_eip ? 1 : 0

  domain = "vpc"
  tags   = local.default_tags
}

resource "aws_eip_association" "this" {
  count = local.create_eip ? 1 : 0

  allocation_id = aws_eip.this[0].id
  instance_id   = aws_instance.this[0].id
}
