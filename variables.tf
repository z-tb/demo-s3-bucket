variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created."
  type        = string
  default     = "us-east-1" # You can change the default to your preferred region
}

variable "bucket_name" {
  description = "The name of the S3 bucket to be created."
  type        = string
}

variable "name_tag" {
  description = "The 'Name' tag for the S3 bucket."
  type        = string
  default     = "default_name"
}

variable "owner_tag" {
  description = "The 'Owner' tag for the S3 bucket."
  type        = string
  default     = "default_owner"
}

variable "environment_tag" {
  description = "The 'Environment' tag for the S3 bucket."
  type        = string
  default     = "default_env"
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