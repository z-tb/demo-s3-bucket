aws_region          = "us-west-2"
bucket_name         = "s3-demo-bucket-27-itpc"

# project tagging tag map
tags = {
    "Project"       = "aws_demo"
    "Owner"         = "tmb"
    "Name"          = "ec2_demo"
    "Environment"   = "dev"
}

# allowed subnets
allowed_subnets     = ["144.92.0.0/16"]

lambda_output_path  = "lambda_functions/lambda_aws.zip"
lambda_source_dir   = "lambda_functions/src"
lambda_runtime      = "python3.8" 
lambda_description  = "s3 bucket demo creates a file in a bucket"

# S3 access
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true


# ec2
ec2_ami_id              = "ami-0cf2b4e024cdb6960"
ec2_instance_type       = "t2.micro"
ec2_availability_zone   = "us-west-2c"