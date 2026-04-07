// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

variable "admin_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GHES administrative shell on port 122 and the management console on port 8443."
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the GHES appliance in the selected AWS region."
  type        = string
}

variable "git_ssh_allowed_cidr_blocks" {
  default     = null
  description = "Optional CIDR blocks allowed to reach Git over SSH on port 22. When null, the module reuses admin_allowed_cidr_blocks."
  type        = list(string)
}

variable "web_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GHES web interface on ports 80 and 443."
  type        = list(string)
}
