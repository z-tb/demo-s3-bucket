# Terraform AWS S3 Bucket Demo

This repository contains Terraform configuration files for provisioning an Amazon S3 bucket on AWS with various security and access control settings. It's intent is to provide a foundation for learning Terraform by provisioning a simple S3 bucket and progressively adding more AWS resources such as resource polices, lambda triggers, IAM policies and data lifecycle tiering.

## Prerequisites

Before you get started, ensure you have the following prerequisites:

- [Terraform](https://www.terraform.io/) installed on your local machine. Due to the recent licensing draw around Terraform, it's recommended to move to [OpenTofo][https://opentofu.org/] at earliest convenience.
  
- Appropriate AWS credentials (access key, secret key and session token) configured in your environment. AWS_REGION is typically defined in the Terraform config but should be exported to the environment also for use with other utilities such as [aws-cli][https://aws.amazon.com/cli/]. Ideally, the credentials being used are temporary and expire in a reasonable amount of time. This way, any secrets possibly leaked into shell history or system/application logs are unsable after a period of time.
  ``` bash
  export AWS_ACCESS_KEY_ID="BEFEQEEWZIF3R1YI42OA"
  export AWS_SECRET_ACCESS_KEY="to...zKF"
  export AWS_SESSION_TOKEN="IA30...G4bC515zE="
  export AWS_REGION="us-east-1"

## Usage

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/z-tb/demo-s3-bucket.git

2. Navigate to the demo-s3-bucket directory:
   ```bash
   cd demo-s3-bucket

3. Create or edit the .tfvars file in this directory and define your variables. For example:

hcl

aws_region              = "us-west-2"
bucket_name             = "my-example-bucket"
name_tag                = "MyExampleBucket"
owner_tag               = "John Doe"
environment_tag         = "development"
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
bucket_key_enabled      = true

Initialize the Terraform configuration:

```bash
terraform init -vars-file="test-env.tfvars"

Apply the configuration:
```bash

    terraform apply -vars-file="test-env.tfvars"

Review the changes and confirm with 'yes' when prompted.

The Terraform configuration will create an S3 bucket with the specified settings.
Configuration

    aws_region: The AWS region where the S3 bucket will be created.
    bucket_name: The name of the S3 bucket.
    name_tag: The 'Name' tag for the S3 bucket.
    owner_tag: The 'Owner' tag for the S3 bucket.
    environment_tag: The 'Environment' tag for the S3 bucket.
    block_public_acls: Set to true to block public ACLs on the S3 bucket.
    block_public_policy: Set to true to block public bucket policies on the S3 bucket.
    ignore_public_acls: Set to true to ignore public ACLs on the S3 bucket.
    restrict_public_buckets: Set to true to restrict the creation of public buckets.
    bucket_key_enabled: Set to true to use a bucket key for encryption; the alternative is using a KMS key for encryption.

License

This project is licensed under the MIT License. See the LICENSE file for details.

csharp


You can now copy and paste this code into your README.md file in your GitHub repository
