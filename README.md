# terraform-aws-ghes

Terraform module for launching a GitHub Enterprise Server appliance on AWS.

When the module creates a VPC, it always creates the CloudWatch log group for VPC flow logs. Set `enable_flow_logs = false` to skip attaching the flow log itself, and keep `enable_flow_logs = false` whenever you provide your own VPC by setting `create_vpc = false`.

## Getting started

### Requirements

- [Terraform] 1.14+

## License

© 2026 [Hachineko].\
All rights reserved.

[hachineko]: https://hachineko.io
[terraform]: https://developer.hashicorp.com/terraform
