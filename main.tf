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
   bucket      = aws_s3_bucket.my_bucket

   rule {
            bucket_key_enabled   = true

            apply_server_side_encryption_by_default {
               sse_algorithm     = "AES256"
            }
   }
}


# Name, environment, owner (many others)
# https://engineering.deptagency.com/best-practices-for-terraform-aws-tags

# Name, Environment, Owner, 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging
