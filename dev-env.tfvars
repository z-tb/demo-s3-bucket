aws_region      = "us-east-1"
bucket_name     = "s3-demo-bucket-swift-puma"  # An Amazon S3 bucket name must bez globally unique
name_tag        = "s3-bucket-demo-dev"
owner_tag       = "tmb"
environment_tag = "development"

# S3 access
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

