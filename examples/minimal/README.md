# Minimal example

This example shows the minimal configuration required to create a GHES appliance
on AWS using this module. You must provide a GHES AMI ID for your target region
and explicit CIDR ranges for web and administrative access.

```bash
terraform init
```

Create a `auto.tfvars` file with the following content before planning or
applying, this will ensure that the created resources are tagged.

```hcl
tags = { "owner" = "unfunco" }
```

```bash
terraform apply
```
