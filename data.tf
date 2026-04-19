// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

data "aws_partition" "this" {
  count = var.create ? 1 : 0
}

data "aws_availability_zones" "available" {
  count = var.create && var.create_vpc && var.primary_availability_zone == null && var.availability_zone == null && var.subnet_cidr_blocks_by_availability_zone == null ? 1 : 0

  state = "available"
}

data "aws_subnet" "existing" {
  count = var.create && !var.create_vpc && var.existing_subnet_id != null ? 1 : 0

  id = var.existing_subnet_id
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_vpc_flow_logs ? 1 : 0

  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = [format("vpc-flow-logs.%s", data.aws_partition.this[0].dns_suffix)]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "vpc_flow_logs" {
  count = local.create_vpc_flow_logs ? 1 : 0

  version = "2012-10-17"

  statement {
    actions   = ["logs:DescribeLogGroups"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"]
  }

  statement {
    actions   = ["logs:PutLogEvents"]
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:log-stream:*"]
  }
}
