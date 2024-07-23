aws_region          = "us-west-2"
bucket_name         = "aws-demo-bucket-2039"

# project tagging tag map
tags = {
    "Project"       = "aws_demo"
    "Owner"         = "abc"
    "Name"          = "ec2_demo"
    "Environment"   = "dev"
}

# allowed subnets
allowed_subnets     = ["0.0.0.0/0"]

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
ec2_ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbUFKGxzkTOWswo7TSw3PVu8C6HvJHuDYlmBSHVu0Wu your_email@example.com"

# rds
db_instance_identifier = "my-postgres-db"
allocated_storage      = 20
storage_type           = "gp2"
engine_version         = "13.15" # valid versions: aws rds describe-db-engine-versions --engine postgres --query "DBEngineVersions[].EngineVersion"
instance_class         = "db.t3.micro"
db_name                = "mydatabase"
parameter_group_name   = "default.postgres13"
postgres_credentials_name = "postgres-credentials"  # this needs to match the aws cli command in rds.tf