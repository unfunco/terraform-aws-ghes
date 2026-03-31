variable "ami_id" {
  description = "AMI ID for the GHES appliance in the selected AWS region."
  type        = string
}

variable "web_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GHES web interface on ports 80 and 443."
  type        = list(string)
}

variable "admin_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GHES administrative shell on port 122 and the management console on port 8443."
  type        = list(string)
}

variable "git_ssh_allowed_cidr_blocks" {
  default     = []
  description = "Optional CIDR blocks allowed to reach Git over SSH on port 22."
  type        = list(string)
}
