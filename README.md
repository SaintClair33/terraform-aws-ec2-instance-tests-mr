# terraform-aws-ec2-instance-tests-{your-initials}
# comment to validate that it triggers a test in HCP TF and ran tf init

A Terraform module for creating EC2 instances with integration tests.

## Usage

```hcl
module "ec2_instances" {
  source = "app.terraform.io/YOUR_ORG/ec2-instance-tests-mr/aws"
  
  instance_count = 2
  instance_type  = "t2.micro"
}