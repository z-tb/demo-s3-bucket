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

variable "lambda_filename" {
  description = "The filename of the lambda function in the lambda_functions/src/ directory."
  type        = string
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