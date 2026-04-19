// SPDX-FileCopyrightText: 2026 Daniel Morris <unfunco@github.com>
// SPDX-License-Identifier: MIT

module "ghes" {
  source = "../.."

  ami_id                 = var.ami_id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = var.tags
}
