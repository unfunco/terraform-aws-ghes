data "aws_partition" "this" {
  count = var.create ? 1 : 0
}

data "aws_region" "this" {
  count = var.create ? 1 : 0
}

data "aws_availability_zones" "available" {
  count = var.create && var.create_vpc && var.availability_zone == null ? 1 : 0

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
