# Minimal example

This example shows the minimal configuration required to create a GHES appliance
on AWS using this module. You must provide a GHES AMI ID for your target region
and explicit CIDR ranges for web and administrative access.

```bash
terraform init
```

```bash
terraform apply \
  -var='ami_id=ami-0123456789abcdef0' \
  -var='web_allowed_cidr_blocks=["203.0.113.0/24"]' \
  -var='admin_allowed_cidr_blocks=["198.51.100.10/32"]' \
  -var='git_ssh_allowed_cidr_blocks=["203.0.113.0/24"]'
```

You can find the correct GHES AMI ID in the GitHub Enterprise Server release
portal or by using the AWS CLI to list GitHub-published AMIs for your AWS
partition.
