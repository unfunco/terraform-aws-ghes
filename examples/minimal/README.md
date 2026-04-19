# Minimal example

This example shows the minimal configuration required to create a GHES appliance
on AWS using this module. You must provide a GHES AMI ID for your target region
and an existing subnet ID. You can also provide security group IDs if you do not
want AWS to use the default security group for that subnet.

```bash
terraform init
```

Create an `auto.tfvars` file with the following content before planning or
applying.

```hcl
ami_id    = "ami-0123456789abcdef0"
subnet_id = "subnet-0123456789abcdef0"

tags = { owner = "unfunco" }
```

```bash
terraform apply
```
