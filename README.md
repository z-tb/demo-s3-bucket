# Terraform AWS S3 Bucket Demo with EC2, VPC, RDS and Fargate tasks

Building on the previous demo branch, this branch creates an AWS Virtual Private Cloud (VPC), associated network 
resources, RDS postgres database and resources to support a python application running in Fargate (ELB, ECR, ECS). 
The purpose is to set up a secure and scalable network infrastructure for deploying applications.

Additional Resources Created:
- VPC: A logically isolated section of the AWS cloud.
- Internet Gateway: Allows communication between the VPC and the internet.
- Public Subnets: Subnets with direct route to the internet gateway.
- Private Subnets: Subnets without direct internet access, for enhanced security.
- NAT Gateways: Allow private subnet resources to access the internet while remaining private.
- Elastic IPs: Static public IP addresses for the NAT Gateways.
- Route Tables: Define routing rules for subnets.
- RDS Postgresql database: see rds.tf for details on implementing the credentials in Secrets Manager.
- Fargate: 
   - Full implementation from the ALB back to the Fargate tasks
      - Volume mount /var/run/docker.sock in your dev container to build the ECR container and push it
         - match the host group perms in the container (eg: docker group/gid via --user-grou)
             you can build and push the docker image into ECR from the dev container.
             (Makefile excerpt below for reference)
    Systems Manager: The ECS configuration is implemented with AWS SSM to allow console access to the task while it's running.
      - useful for debugging
      - see comments in fargate.tf for more details


Benefits
    Secure deployment of public-facing and private resources.
    High availability across multiple Availability Zones.
    Controlled internet access for private resources.


Note
The EC2 instance will be launched in one of the existing public subnets indicated by the chosen availability zone. To ensure that the EC2 instance is launched in the same Availability Zone (AZ) as the specified public subnet, the aws_subnet data source is used to find the correct subnet based on the ec2_availability_zone variable.

Be sure to regenerate an ED25519 ssh key (see the ec2.tf) so you can ssh into your ec2.
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

### using Docker in the dev container
To set up Docker-in-Docker (DinD) for building and pushing images to Amazon ECR, you'll need to mount the Docker socket and properly configure permissions. 

The host system will look something like this:
```bash
ls -l /var/run/docker.sock
# srw-rw---- 1 root docker 0 Jan 28 14:23 /var/run/docker.sock
```
You will need to match the group permission in the container. 

    eg: The Docker socket (/var/run/docker.sock) is owned by root:docker with group ID 999

The container user must be in the same group (GID 999) to access the socket. Without doing this, you'll get "permission denied" errors when trying to use Docker commands in the dev container.

Below is a Makefile target I use for running a dev container for working with Fargate. Be aware that root in the container will have root access to your host Docker daemon this way. This is not suitable for production use since a compromised process in the container can potentially access your host system docker daemon. 

```bash
runmhdock:
        docker run -it --rm \
        --hostname $(IMAGE_NAME) \
        --user ${USER_UID}:${USER_GROUP_GID} \
        --group-add docker \
        --group-add ${DOCKER_GID} \
        --name ${CONTAINER_NAME} \
        --volume ${HOST_PATH}:${CONT_APP_MNT} \
        --volume ${USER_HOME}:/mnt/${USER_HOME}:ro \
        --volume ${DOCKER_SOCKET}:${CONT_DOCKER_SOCKET} \
        ${IMAGE_NAME}:${IMAGE_VERSION}
```        

## License

This project is licensed under the MIT License. See the LICENSE file for details.
