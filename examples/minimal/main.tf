module "ghes" {
  source = "../.."

  ami_id                      = var.ami_id
  web_allowed_cidr_blocks     = var.web_allowed_cidr_blocks
  admin_allowed_cidr_blocks   = var.admin_allowed_cidr_blocks
  git_ssh_allowed_cidr_blocks = var.git_ssh_allowed_cidr_blocks
}
