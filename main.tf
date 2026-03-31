locals {
  create_eip           = var.create && var.create_eip
  create_kms_key       = var.create && var.kms_key_arn == null
  create_vpc           = var.create && var.create_vpc
  create_vpc_flow_logs = var.create && var.create_vpc && var.create_vpc_flow_logs

  default_tags = merge({
    "terraform-module" = "hachinekoresearch/terraform-aws-ghes"
  }, var.tags)

  resolved_ami_id = !var.create ? null : (
    var.ami_id != null ? trimspace(var.ami_id) : try(
      length(trimspace(var.ami_id_by_region[data.aws_region.this[0].region])) > 0
      ? trimspace(var.ami_id_by_region[data.aws_region.this[0].region])
      : null,
      null
    )
  )

  appliance_ami_id    = coalesce(local.resolved_ami_id, "ami-00000000000000000")
  appliance_public_ip = one(aws_eip.this[*].public_ip)

  git_ssh_allowed_cidr_blocks = var.create ? coalesce(var.git_ssh_allowed_cidr_blocks, var.admin_allowed_cidr_blocks) : []

  resolved_kms_key_arn = var.create ? coalesce(one(aws_kms_key.this[*].arn), var.kms_key_arn) : null
  resolved_subnet_id   = var.create ? one(concat(aws_subnet.this[*].id, data.aws_subnet.existing[*].id)) : null
  resolved_vpc_id      = var.create ? one(concat(aws_vpc.this[*].id, data.aws_subnet.existing[*].vpc_id)) : null

  selected_availability_zone = coalesce(
    var.availability_zone,
    one(data.aws_availability_zones.available[*].names[0]),
  )
}

resource "aws_kms_key" "this" {
  count = local.create_kms_key ? 1 : 0

  deletion_window_in_days = 30
  description             = "GHES appliance encryption key"
  enable_key_rotation     = true
  tags                    = local.default_tags
}

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags                 = local.default_tags
}

resource "aws_internet_gateway" "this" {
  count = local.create_vpc ? 1 : 0

  tags   = local.default_tags
  vpc_id = aws_vpc.this[0].id
}

resource "aws_route_table" "this" {
  count = local.create_vpc ? 1 : 0

  tags   = local.default_tags
  vpc_id = aws_vpc.this[0].id
}

resource "aws_route" "internet_gateway" {
  count = local.create_vpc ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  route_table_id         = aws_route_table.this[0].id
}

resource "aws_subnet" "this" {
  count = local.create_vpc ? 1 : 0

  availability_zone       = local.selected_availability_zone
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = false
  tags                    = local.default_tags
  vpc_id                  = aws_vpc.this[0].id
}

resource "aws_route_table_association" "this" {
  count = local.create_vpc ? 1 : 0

  route_table_id = aws_route_table.this[0].id
  subnet_id      = aws_subnet.this[0].id
}

resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  description = "Security group for the GHES appliance"
  name_prefix = "ghes-"
  tags        = local.default_tags
  vpc_id      = local.resolved_vpc_id
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.this[0].id
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each = toset(var.create ? var.web_allowed_cidr_blocks : [])

  cidr_ipv4         = each.value
  description       = "Allow HTTP access to the GHES web interface"
  from_port         = 80
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.this[0].id
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  for_each = toset(var.create ? var.web_allowed_cidr_blocks : [])

  cidr_ipv4         = each.value
  description       = "Allow HTTPS access to the GHES web interface"
  from_port         = 443
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.this[0].id
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "git_ssh" {
  for_each = toset(local.git_ssh_allowed_cidr_blocks)

  cidr_ipv4         = each.value
  description       = "Allow Git over SSH access to the GHES appliance"
  from_port         = 22
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.this[0].id
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "admin_https" {
  for_each = toset(var.create ? var.admin_allowed_cidr_blocks : [])

  cidr_ipv4         = each.value
  description       = "Allow HTTPS access to the GHES management console"
  from_port         = 8443
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.this[0].id
  to_port           = 8443
}

resource "aws_vpc_security_group_ingress_rule" "admin_ssh" {
  for_each = toset(var.create ? var.admin_allowed_cidr_blocks : [])

  cidr_ipv4         = each.value
  description       = "Allow SSH access to the GHES administrative shell"
  from_port         = 122
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.this[0].id
  to_port           = 122
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = local.create_vpc_flow_logs ? 1 : 0

  kms_key_id        = local.resolved_kms_key_arn
  log_group_class   = "STANDARD"
  name              = "/aws/vpc/flow-logs/${aws_vpc.this[0].id}"
  retention_in_days = var.log_retention_in_days
  skip_destroy      = false
  tags              = local.default_tags
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = local.create_vpc_flow_logs ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  name_prefix        = "ghes-vpc-flow-logs-"
  tags               = local.default_tags
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = local.create_vpc_flow_logs ? 1 : 0

  name = "write-cloudwatch-logs"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_logs[0].arn,
          "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
  role = aws_iam_role.vpc_flow_logs[0].id
}

resource "aws_flow_log" "this" {
  count      = local.create_vpc_flow_logs ? 1 : 0
  depends_on = [aws_iam_role_policy.vpc_flow_logs]

  iam_role_arn         = aws_iam_role.vpc_flow_logs[0].arn
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  tags                 = local.default_tags
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this[0].id
}

resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  ami                         = local.appliance_ami_id
  associate_public_ip_address = false
  iam_instance_profile        = var.instance_profile_name
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = local.resolved_subnet_id
  tenancy                     = "default"
  volume_tags                 = local.default_tags
  vpc_security_group_ids      = [aws_security_group.this[0].id]
  tags                        = local.default_tags

  lifecycle {
    precondition {
      condition     = local.resolved_ami_id != null
      error_message = "Provide ami_id or populate ami_id_by_region for the current AWS region."
    }

    precondition {
      condition     = var.create_vpc || var.existing_subnet_id != null
      error_message = "existing_subnet_id must be set when create_vpc is false."
    }
  }

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
    iops                  = 3000
    kms_key_id            = local.resolved_kms_key_arn
    throughput            = 125
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = var.data_volume_device_name
    encrypted             = true
    iops                  = 3000
    kms_key_id            = local.resolved_kms_key_arn
    throughput            = 125
    volume_size           = var.data_volume_size
    volume_type           = "gp3"
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
