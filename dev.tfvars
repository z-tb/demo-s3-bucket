aws_region          = "us-west-2"
bucket_name         = "s3-demo-bucket-30-itpc"
name_tag            = "s3-bucket-demo-dev"
owner_tag           = "tmb"
environment_tag     = "itpc"
lambda_filename     = "s3-copy.py"
lambda_output_path  = "lambda_functions/zipzip.zip"
lambda_source_dir   = "lambda_functions/src"
lambda_runtime      = "python3.8" 

# S3 access
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

