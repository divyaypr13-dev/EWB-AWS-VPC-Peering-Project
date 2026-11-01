# Optional: Terraform version of the same build

The workbook expects you to understand each console step. Build it by hand first, or use this to rebuild quickly. Evidence must still come from your own AWS account and your own screenshots.

Not tested in the authoring environment: run `terraform validate` first and read the plan before applying.

## Prerequisites
- Terraform >= 1.5 and AWS credentials (for example AWS CloudShell, which also has the AWS CLI).
- A key pair named `ewb-lab` already created in the EC2 console (download the .pem to your laptop only).

## Flow that matches the workbook tests
1. `cp terraform.tfvars.example terraform.tfvars` and edit it. Keep `enable_peering = false`.
2. `terraform init` then `terraform apply`. This builds VPCs, subnets, IGW, route tables, security groups and instances.
3. SSH in (see ../ssh/config.example), screenshot the baseline: App-A `ping -c 4 10.20.1.10` must fail.
4. Set `enable_peering = true` and run `terraform apply`. This creates and accepts `ewb-a-b-peer` and adds the three routes.
5. Run the verification tests, then the controlled failure in the console (remove and restore the App-B ICMP rule). Run `terraform plan` afterwards: it will show that rule as drift, and `terraform apply` restores it.
6. Take all console screenshots before cleanup.
7. `terraform destroy` removes everything it created. The key pair is not managed by Terraform, so delete it manually.

Never commit `terraform.tfvars`, `*.tfstate` or any .pem file.
