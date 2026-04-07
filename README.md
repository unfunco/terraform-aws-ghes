# terraform-aws-ghes

Terraform module for launching a [GitHub Enterprise Server] appliance on AWS.

## Getting started

### Requirements

- [Terraform] 1.14+

### Usage instructions

<!-- x-release-please-start-version -->

```terraform
module "ghes" {
  source = "git:github.com/hachinekoresearch/terraform-aws-ghes.git?ref=v0.0.0"
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

[github enterprise server]: https://docs.github.com/en/enterprise-server
[hachineko research]: https://hachineko.io
[mit licence]: LICENSE.md
[terraform]: https://developer.hashicorp.com/terraform
