// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

module "ghes" {
  source = "../.."

  admin_allowed_cidr_blocks   = var.admin_allowed_cidr_blocks
  ami_id                      = var.ami_id
  git_ssh_allowed_cidr_blocks = var.git_ssh_allowed_cidr_blocks
  web_allowed_cidr_blocks     = var.web_allowed_cidr_blocks
}
