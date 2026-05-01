// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

variable "cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC."
  type        = string
}

variable "appliance_ami_id" {
  description = "AMI ID for the GHES appliance. Consumers must provide this explicitly."
  type        = string
}

variable "azs" {
  description = "Availability zones used for the example VPC. Provide at least two to place the primary and replica in different subnets."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "azs must contain at least two availability zones."
  }
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
}

variable "data_volume_iops" {
  default     = null
  description = "Provisioned IOPS for the GHES data volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS."
  type        = number
}

variable "data_volume_size" {
  default     = 500
  description = "Size in GiB for the encrypted GHES data volume. GHES currently requires at least 500 GiB."
  type        = number
}

variable "data_volume_throughput" {
  default     = null
  description = "Provisioned throughput in MiB/s for the GHES data volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput."
  type        = number
}

variable "data_volume_type" {
  default     = "gp3"
  description = "EBS volume type for the GHES data volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads."
  type        = string
}

variable "ebs_optimized" {
  default     = null
  description = "Whether to enable EBS optimization for the GHES appliance. When null, AWS provider defaults apply."
  type        = bool
}

variable "enable_flow_log" {
  default     = true
  description = "Whether to enable VPC flow logs."
  type        = bool
}

variable "enable_nat_gateway" {
  default     = true
  description = "Whether to create a NAT gateway for the VPC."
  type        = bool
}

variable "flow_log_traffic_type" {
  default     = "ALL"
  description = "Type of traffic to capture in VPC flow logs. Accepted values are ACCEPT, REJECT, or ALL."
  type        = string
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
  description = "Optional EC2 key pair name to associate with the GHES appliances."
  type        = string
}

variable "kms_key_arn" {
  default     = null
  description = "KMS key ARN for encrypted resources. When null, this example creates and shares one key between the instances and VPC flow logs."
  type        = string
}

variable "log_retention_in_days" {
  default     = 14
  description = "Number of days to retain CloudWatch log groups."
  type        = number
}

variable "name" {
  default     = "github-enterprise-server"
  description = "Name to use for the GHES appliance and related resources."
  type        = string
}

variable "root_volume_iops" {
  default     = null
  description = "Provisioned IOPS for the GHES root volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS."
  type        = number
}

variable "root_volume_size" {
  default     = 400
  description = "Size in GiB for the encrypted GHES root disk. GHES currently requires at least 400 GiB, and this disk is separate from the data volume."
  type        = number
}

variable "root_volume_throughput" {
  default     = null
  description = "Provisioned throughput in MiB/s for the GHES root volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput."
  type        = number
}

variable "root_volume_type" {
  default     = "gp3"
  description = "EBS volume type for the GHES root volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}
