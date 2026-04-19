// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

output "ami_id" {
  description = "AMI ID provided for the GHES appliance."
  value       = local.resolved_ami_id
}

output "data_volume_id" {
  description = "EBS volume ID for the attached GHES data volume."
  value = try(one(flatten([
    for appliance in aws_instance.this : [
      for block_device in appliance.ebs_block_device : block_device.volume_id
      if block_device.device_name == var.data_volume_device_name
    ]
  ])), null)
}

output "instance_id" {
  description = "EC2 instance ID for the GHES appliance."
  value       = try(one(aws_instance.this[*].id), null)
}

output "instance_private_ip" {
  description = "Private IPv4 address assigned to the GHES appliance."
  value       = try(one(aws_instance.this[*].private_ip), null)
}

output "instance_public_ip" {
  description = "Public IPv4 address for the GHES appliance when one is available."
  value       = local.appliance_public_ip
}

output "kms_key_arn" {
  description = "KMS key ARN used for encrypted resources."
  value       = local.resolved_kms_key_arn
}

output "subnet_id" {
  description = "Subnet ID used for the GHES appliance."
  value       = var.subnet_id
}
