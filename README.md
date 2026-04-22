# terraform-aws-ghes

Terraform module for launching a single [GitHub Enterprise Server] appliance on
Amazon Web Services. It focuses on the appliance itself and leaves VPC, subnet,
route table, and security group management to the calling stack.

## Getting started

### Requirements

- [AWS Command Line Interface] 2+
- [Terraform] 1.14+

### Usage instructions

<!-- x-release-please-start-version -->

```terraform
module "ghes" {
  source = "github.com/hachinekoresearch/terraform-aws-ghes?ref=v0.1.0"
  ami_id                 = "ami-0123456789abcdef0"
  subnet_id              = "subnet-0123456789abcdef0"
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
}
```

<!-- x-release-please-end -->

#### Finding the GHES AMI ID

```bash
aws ec2 describe-images \
  --output "text" \
  --owners "895557238572" \
  --query "sort_by(Images,&Name)[*].{Name:Name,ImageID:ImageId}"
```

## License

© 2026 [Hachineko Research].\
Made available under the terms of the [MIT Licence].

[aws command line interface]: https://aws.amazon.com/cli/
[github enterprise server]: https://docs.github.com/en/enterprise-server
[hachineko research]: https://hachineko.io
[mit licence]: LICENSE.md
[terraform]: https://developer.hashicorp.com/terraform
