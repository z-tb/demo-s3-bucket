# Terraform AWS S3 Bucket Demo

This repository contains Terraform configuration files for provisioning Amazon AWS infrastructure with an S3 bucket, Lambda function, Cloudwatch event and the various security and access controls needed for the resource to interact with each other. The intent is to provide a foundation to demo how the various pieces are applied through Terraform.

## Prerequisites

Before you get started, ensure you have the following prerequisites:

- [Terraform](https://www.terraform.io/) installed on your local machine. Due to the recent licensing issues around Terraform, it may be in your interest to switch to [OpenTofo](https://opentofu.org/) at the earliest convenience.
  
- Appropriate AWS credentials (access key, secret key, and session token) configured in your environment. `AWS_REGION` is typically defined in the Terraform config but should be exported to the environment also for use with other utilities such as [aws-cli](https://aws.amazon.com/cli/). Ideally, the credentials being used are temporary and expire in a reasonable amount of time. This way, any secrets possibly leaked into shell history or system/application logs are unusable after a period of time.
  ```bash
  export AWS_ACCESS_KEY_ID="BEFEQEEWZIF3R1YI42OA"
  export AWS_SECRET_ACCESS_KEY="to...zKF"
  export AWS_SESSION_TOKEN="IA30...G4bC515zE="
  export AWS_REGION="us-east-1"
  ```

## Usage

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/z-tb/demo-s3-bucket.git
   ```

2. Navigate to the demo-s3-bucket directory:
   ```bash
   cd demo-s3-bucket
   ```

3. Create or edit the .tfvars file in this directory and define your variables. For example:
   ```hcl
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
   ```

4. Initialize the Terraform configuration:
   ```bash
   terraform init -var-file="dev.tfvars"
   ```

5. Apply the configuration using the same `.tfvars` file:
   ```bash
   terraform apply -var-file="dev.tfvars"
   ```

Review the changes and confirm with 'yes' when prompted.

The Terraform configuration will create an S3 bucket with the specified settings.

### Makefile Usage

The Makefile provides a set of convenient commands for managing Terraform configurations for different environments. It includes tasks for initializing, planning, applying, and destroying resources. It is configured to use OpenTofu by default so if you have Terraform installed, change the `TF` variable.

The following commands/targets are in the Makefile:

#### Initialize Terraform

```bash
make init
```

This command initializes Terraform using the var-file corresponding to the specified environment (dev or prod).

#### Reconfigure Terraform

```bash
make reconfig
```

This command reconfigures Terraform setup, initializing it with reconfiguration using the var-file corresponding to the specified environment.

#### Plan Terraform Changes

```bash
make plan
```

This command generates an execution plan for Terraform changes using the var-file corresponding to the specified environment.

#### Apply Terraform Changes

```bash
make apply
```

This command applies Terraform changes using the var-file corresponding to the specified environment.

#### Destroy Terraform Resources

```bash
make destroy
```

This command destroys Terraform-managed infrastructure using the var-file corresponding to the specified environment.

### Environment Variables

- **TF**: Set to "tofu", representing the Terraform executable.
- **ENV**: Set to "dev" by default, can be overridden to "prod" or any other environment.

### Colorization

The output of each command is colorized for better readability:
- **Green**: Indicates a dev environment.
- **Red**: Indicates a non-dev environment.
- **Reset**: Resets color settings after the message.

### Vim Modeline

The Vim modeline at the end of the file provides syntax highlighting and indentation settings for the Vim text editor.

```bash
# Vim modeline
# vim: syntax=make ts=8 sw=8 noet
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
