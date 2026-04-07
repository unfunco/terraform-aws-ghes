// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

variable "admin_allowed_cidr_blocks" {
  default     = []
  description = "CIDR blocks allowed to reach the GHES administrative shell on port 122 and the management console on port 8443."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr_block in var.admin_allowed_cidr_blocks : can(cidrhost(cidr_block, 0))
    ])
    error_message = "admin_allowed_cidr_blocks must contain valid IPv4 CIDR blocks."
  }
}

variable "ami_id" {
  default     = null
  description = "AMI ID for the GHES appliance. When null, the module uses the current AWS region entry from ami_id_by_region."
  type        = string

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "ami_id must look like an AWS AMI ID."
  }
}

variable "ami_id_by_region" {
  default     = {}
  description = "AWS region-to-GHES AMI ID map. Set the current region entry, or set ami_id directly."
  type        = map(string)

  validation {
    condition = alltrue([
      for mapped_ami_id in values(var.ami_id_by_region) : trimspace(mapped_ami_id) == "" || can(regex("^ami-[0-9a-f]+$", trimspace(mapped_ami_id)))
    ])
    error_message = "ami_id_by_region values must be empty strings or valid AWS AMI IDs."
  }
}

variable "availability_zone" {
  default     = null
  description = "Availability Zone for the module-managed subnet. When null, the module uses the first available zone."
  type        = string
}

variable "create" {
  default     = true
  description = "Whether to create resources in this module."
  type        = bool
}

variable "create_eip" {
  default     = true
  description = "Whether to allocate and associate an Elastic IP with the GHES appliance."
  type        = bool
}

variable "create_vpc" {
  default     = true
  description = "Whether to create the VPC and subnet for the GHES appliance."
  type        = bool
}

variable "data_volume_device_name" {
  default     = "/dev/xvdf"
  description = "EC2 device name for the attached GHES data volume."
  type        = string

  validation {
    condition     = can(regex("^/dev/[A-Za-z0-9]+$", var.data_volume_device_name))
    error_message = "data_volume_device_name must look like an EC2 device path, for example /dev/xvdf."
  }
}

variable "data_volume_iops" {
  default     = null
  description = "Provisioned IOPS for the GHES data volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS."
  type        = number

  validation {
    condition     = var.data_volume_iops == null || var.data_volume_iops > 0
    error_message = "data_volume_iops must be greater than zero when provided."
  }

  validation {
    condition     = var.data_volume_iops == null || contains(["gp3", "io1", "io2"], var.data_volume_type)
    error_message = "data_volume_iops can be set only when data_volume_type is gp3, io1, or io2."
  }
}

variable "data_volume_size" {
  default     = 500
  description = "Size in GiB for the encrypted GHES data volume. GHES currently requires at least 500 GiB."
  type        = number

  validation {
    condition     = var.data_volume_size >= 500
    error_message = "data_volume_size must be at least 500 GiB for current GHES releases."
  }
}

variable "data_volume_throughput" {
  default     = null
  description = "Provisioned throughput in MiB/s for the GHES data volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput."
  type        = number

  validation {
    condition     = var.data_volume_throughput == null || var.data_volume_throughput > 0
    error_message = "data_volume_throughput must be greater than zero when provided."
  }

  validation {
    condition     = var.data_volume_throughput == null || var.data_volume_type == "gp3"
    error_message = "data_volume_throughput can be set only when data_volume_type is gp3."
  }
}

variable "data_volume_type" {
  default     = "gp3"
  description = "EBS volume type for the GHES data volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads."
  type        = string

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1", "standard"], var.data_volume_type)
    error_message = "data_volume_type must be one of gp2, gp3, io1, io2, st1, sc1, or standard."
  }
}

variable "ebs_optimized" {
  default     = null
  description = "Whether to enable EBS optimization for the GHES appliance. When null, AWS provider defaults apply."
  type        = bool
}

variable "enable_flow_logs" {
  default     = true
  description = "Whether to enable VPC flow logs for the module-managed VPC. This must be false when create_vpc is false."
  type        = bool

  validation {
    condition     = !var.create || var.create_vpc || !var.enable_flow_logs
    error_message = "enable_flow_logs must be false when create_vpc is false."
  }
}

variable "existing_subnet_id" {
  default     = null
  description = "Subnet ID to use when create_vpc is false."
  type        = string

  validation {
    condition     = !var.create || var.create_vpc || var.existing_subnet_id != null
    error_message = "existing_subnet_id must be provided when create_vpc is false."
  }

  validation {
    condition     = !var.create || !var.create_vpc || var.existing_subnet_id == null
    error_message = "existing_subnet_id must be null when create_vpc is true."
  }
}

variable "git_ssh_allowed_cidr_blocks" {
  default     = null
  description = "Optional CIDR blocks allowed to reach Git over SSH on port 22. When null, the module reuses admin_allowed_cidr_blocks."
  type        = list(string)

  validation {
    condition = var.git_ssh_allowed_cidr_blocks == null || alltrue([
      for cidr_block in var.git_ssh_allowed_cidr_blocks : can(cidrhost(cidr_block, 0))
    ])
    error_message = "git_ssh_allowed_cidr_blocks must contain valid IPv4 CIDR blocks when provided."
  }
}

variable "instance_profile_name" {
  default     = null
  description = "IAM instance profile name to attach to the GHES appliance."
  type        = string
}

variable "instance_type" {
  default     = "r5.2xlarge"
  description = "EC2 instance type for the GHES appliance."
  type        = string
}

variable "key_name" {
  default     = null
  description = "Optional EC2 key pair name to associate with the GHES appliance."
  type        = string
}

variable "kms_key_arn" {
  default     = null
  description = "KMS key ARN for encrypted resources. When null, the module creates a key."
  type        = string

  validation {
    condition     = var.kms_key_arn == null || startswith(var.kms_key_arn, "arn:")
    error_message = "kms_key_arn must be a KMS key ARN when provided."
  }
}

variable "log_retention_in_days" {
  default     = 365
  description = "Retention period in days for module-managed CloudWatch log groups."
  type        = number

  validation {
    condition     = var.log_retention_in_days > 0
    error_message = "log_retention_in_days must be greater than zero."
  }
}

variable "root_volume_size" {
  default     = 400
  description = "Size in GiB for the encrypted GHES root disk. GHES currently requires at least 400 GiB, and this disk is separate from the data volume."
  type        = number

  validation {
    condition     = var.root_volume_size >= 400
    error_message = "root_volume_size must be at least 400 GiB for current GHES releases."
  }
}

variable "root_volume_iops" {
  default     = null
  description = "Provisioned IOPS for the GHES root volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS."
  type        = number

  validation {
    condition     = var.root_volume_iops == null || var.root_volume_iops > 0
    error_message = "root_volume_iops must be greater than zero when provided."
  }

  validation {
    condition     = var.root_volume_iops == null || contains(["gp3", "io1", "io2"], var.root_volume_type)
    error_message = "root_volume_iops can be set only when root_volume_type is gp3, io1, or io2."
  }
}

variable "root_volume_throughput" {
  default     = null
  description = "Provisioned throughput in MiB/s for the GHES root volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput."
  type        = number

  validation {
    condition     = var.root_volume_throughput == null || var.root_volume_throughput > 0
    error_message = "root_volume_throughput must be greater than zero when provided."
  }

  validation {
    condition     = var.root_volume_throughput == null || var.root_volume_type == "gp3"
    error_message = "root_volume_throughput can be set only when root_volume_type is gp3."
  }
}

variable "root_volume_type" {
  default     = "gp3"
  description = "EBS volume type for the GHES root volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads."
  type        = string

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.root_volume_type)
    error_message = "root_volume_type must be one of gp2, gp3, io1, io2, or standard."
  }
}

variable "subnet_cidr_block" {
  default     = "10.0.0.0/24"
  description = "CIDR block for the module-managed subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "subnet_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  default     = {}
  description = "Additional tags to apply to module-managed resources."
  type        = map(string)
}

variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the module-managed VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "web_allowed_cidr_blocks" {
  default     = []
  description = "CIDR blocks allowed to reach the GHES web interface on ports 80 and 443."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr_block in var.web_allowed_cidr_blocks : can(cidrhost(cidr_block, 0))
    ])
    error_message = "web_allowed_cidr_blocks must contain valid IPv4 CIDR blocks."
  }
}
