// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

variable "ami_id" {
  description = "AMI ID for the GHES appliance."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the GHES appliance will be launched."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}

variable "vpc_security_group_ids" {
  default     = null
  description = "Optional security group IDs to attach to the GHES appliance."
  type        = list(string)
}
