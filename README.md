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
  source  = "unfunco/ghes/aws"
  version = "0.2.0"

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

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                    | Type     |
| ----------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                         | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)               | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                 | resource |

### Inputs

| Name                    | Description                                                                                                                                              | Type           | Default        | Required |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------- | :------: |
| ami_id                  | AMI ID for the GHES appliance. Consumers must provide this explicitly.                                                                                   | `string`       | n/a            |   yes    |
| create                  | Whether to create resources in this module.                                                                                                              | `bool`         | `true`         |    no    |
| create_eip              | Whether to allocate and associate an Elastic IP with the GHES appliance.                                                                                 | `bool`         | `true`         |    no    |
| data_volume_device_name | EC2 device name for the attached GHES data volume.                                                                                                       | `string`       | `"/dev/xvdf"`  |    no    |
| data_volume_iops        | Provisioned IOPS for the GHES data volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS.        | `number`       | `null`         |    no    |
| data_volume_size        | Size in GiB for the encrypted GHES data volume. GHES currently requires at least 500 GiB.                                                                | `number`       | `500`          |    no    |
| data_volume_throughput  | Provisioned throughput in MiB/s for the GHES data volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput. | `number`       | `null`         |    no    |
| data_volume_type        | EBS volume type for the GHES data volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads.                          | `string`       | `"gp3"`        |    no    |
| ebs_optimized           | Whether to enable EBS optimization for the GHES appliance. When null, AWS provider defaults apply.                                                       | `bool`         | `null`         |    no    |
| instance_profile_name   | IAM instance profile name to attach to the GHES appliance.                                                                                               | `string`       | `null`         |    no    |
| instance_type           | EC2 instance type for the GHES appliance.                                                                                                                | `string`       | `"r5.2xlarge"` |    no    |
| key_name                | Optional EC2 key pair name to associate with the GHES appliance.                                                                                         | `string`       | `null`         |    no    |
| kms_key_arn             | KMS key ARN for encrypted resources. When null, the module creates a key.                                                                                | `string`       | `null`         |    no    |
| root_volume_iops        | Provisioned IOPS for the GHES root volume when using gp3, io1, or io2. Defaults to 3000 when the selected volume type supports configurable IOPS.        | `number`       | `null`         |    no    |
| root_volume_size        | Size in GiB for the encrypted GHES root disk. GHES currently requires at least 400 GiB, and this disk is separate from the data volume.                  | `number`       | `400`          |    no    |
| root_volume_throughput  | Provisioned throughput in MiB/s for the GHES root volume when using gp3. Defaults to 125 when the selected volume type supports configurable throughput. | `number`       | `null`         |    no    |
| root_volume_type        | EBS volume type for the GHES root volume. GitHub recommends SSD-backed types such as gp3, io1, or io2 for production workloads.                          | `string`       | `"gp3"`        |    no    |
| subnet_id               | Subnet ID where the GHES appliance should be launched. Networking is expected to be managed outside this module.                                         | `string`       | n/a            |   yes    |
| tags                    | Tags to be applied to all applicable resources.                                                                                                          | `map(string)`  | `{}`           |    no    |
| vpc_security_group_ids  | Optional security group IDs to attach to the GHES appliance. When null, AWS uses the subnet's default security group.                                    | `list(string)` | `null`         |    no    |

### Outputs

| Name                | Description                                                       |
| ------------------- | ----------------------------------------------------------------- |
| ami_id              | AMI ID provided for the GHES appliance.                           |
| data_volume_id      | EBS volume ID for the attached GHES data volume.                  |
| instance_id         | EC2 instance ID for the GHES appliance.                           |
| instance_private_ip | Private IPv4 address assigned to the GHES appliance.              |
| instance_public_ip  | Public IPv4 address for the GHES appliance when one is available. |
| kms_key_arn         | KMS key ARN used for encrypted resources.                         |
| subnet_id           | Subnet ID used for the GHES appliance.                            |

<!-- END_TF_DOCS -->

## License

© 2026 [Daniel Morris].\
Made available under the terms of the [MIT Licence].

[aws command line interface]: https://aws.amazon.com/cli/
[daniel morris]: https://unfun.co
[github enterprise server]: https://docs.github.com/en/enterprise-server
[mit licence]: LICENSE.md
[terraform]: https://developer.hashicorp.com/terraform
