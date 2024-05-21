aws_region          = "us-west-2"
bucket_name         = "s3-demo-bucket-30-itpc"
name_tag            = "s3-bucket-demo"  # python src file needs to be named this as well
owner_tag           = "tmb"
environment_tag     = "itpc"
lambda_output_path  = "lambda_functions/lambda_aws.zip"
lambda_source_dir   = "lambda_functions/src"
lambda_runtime      = "python3.8" 

# S3 access
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

