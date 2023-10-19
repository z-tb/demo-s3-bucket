# 
# terraform init -var-file="test-env.tfvars"
# 

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.name_tag
    Owner       = var.owner_tag
    Environment = var.environment_tag
  }
}  
  

# S3 bucket encryption - bucket key and AES
resource "aws_s3_bucket_server_side_encryption_configuration" "my_s3_bucket_encryption" {
   bucket      = aws_s3_bucket.my_bucket.bucket

   rule {
            bucket_key_enabled   = var.bucket_key_enabled

            apply_server_side_encryption_by_default {
               sse_algorithm     = "AES256"
            }
   }
}


# TODO: Add aws_s3_public_access block - this is now the default but a good exercise
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block