variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created."
  type        = string
  default     = "us-east-1" # You can change the default to your preferred region
}

variable "bucket_name" {
  description = "The name of the S3 bucket to be created."
  type        = string
  default     = "default-bucket-name"
}

variable "name_tag" {
  description = "The 'Name' tag for the S3 bucket."
  type        = string
  default     = "default-name-tag"
}

variable "owner_tag" {
  description = "The 'Owner' tag for the S3 bucket."
  type        = string
  default     = "default-owner-tag"
}

variable "environment_tag" {
  description = "The 'Environment' tag for the S3 bucket."
  type        = string
  default     = "default-env-tag"
}

variable "block_public_acls" {
  description = "Set to true to block public ACLs on the S3 bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Set to true to block public bucket policies on the S3 bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Set to true to ignore public ACLs on the S3 bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Set to true to restrict the creation of public buckets."
  type        = bool
  default     = true
}

# default to always use a bucket key for encryption
variable "bucket_key_enabled" {
  description = "Set to true to use a bucket key for encryption. The alternative is KMS key which == $$"
  type        = bool
  default     = true
}

variable "lambda_source_dir" {
  description = "the directory containing the lambda function source code."
  type        = string
}

variable "lambda_output_path" {
  description = "where to place the zip file of the lambda function."
  type        = string
}

variable "lambda_runtime" {
  description = "the runtime interpreter for the lambda function - ruby2.7, nodejs12.x, python3.8, etc, etc"
  type        = string
}

variable "log_retention_in_days" {
  description = "number of days to keep log group cloudwatch logs"
  type        = number
  default     = 7
}

variable "lambda_description" {
  description = "description of the lambda function"
  type        = string
  default     = "default-lambda-description"
}

#--- EC2 variables
variable "ec2_ami_id" {
  description = "The ID of the AMI to use for the EC2 instance."
  type        = string
}

variable "ec2_instance_type" {
  description = "value of the EC2 instance type."
  type        = string
}

variable "ec2_availability_zone" {
  description = "value of the EC2 instance availability zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)

  default     = {
    Project = "NotSure"
    Owner   = "NotSure"
    Name    = "NotSure"
    Environment = "undefined"
  }
}

variable "allowed_subnets" {
  description = "List of allowed subnets for vpc resources"
  type    = list(string)
  default = ["192.168.1.0/24"]
}

#--- VPC variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]  # Adjust CIDR blocks as needed
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]  # Adjust CIDR blocks as needed
}

# List of availability zones
variable "availability_zones" {
  description = "List of availability zones for subnets"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

