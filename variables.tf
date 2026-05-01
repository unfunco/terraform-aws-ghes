// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

variable "ami_id" {
  description = "AMI ID for the GHES appliance. Consumers must provide this explicitly."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", trimspace(var.ami_id)))
    error_message = "ami_id must be provided and look like an AWS AMI ID."
  }
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

variable "root_volume_size" {
  default     = 400
  description = "Size in GiB for the encrypted GHES root disk. GHES currently requires at least 400 GiB, and this disk is separate from the data volume."
  type        = number

  validation {
    condition     = var.root_volume_size >= 400
    error_message = "root_volume_size must be at least 400 GiB for current GHES releases."
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

variable "subnet_id" {
  description = "Subnet ID where the GHES appliance should be launched. Networking is expected to be managed outside this module."
  type        = string

  validation {
    condition     = can(regex("^subnet-[0-9a-z]+$", trimspace(var.subnet_id)))
    error_message = "subnet_id must be provided and look like an AWS subnet ID."
  }
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}

variable "vpc_security_group_ids" {
  default     = null
  description = "Optional security group IDs to attach to the GHES appliance. When null, AWS uses the subnet's default security group."
  type        = list(string)

  validation {
    condition = var.vpc_security_group_ids == null || (
      length(var.vpc_security_group_ids) > 0 && alltrue([
        for security_group_id in var.vpc_security_group_ids : can(regex("^sg-[0-9a-z]+$", trimspace(security_group_id)))
      ])
    )
    error_message = "vpc_security_group_ids must contain valid AWS security group IDs when provided."
  }
}
