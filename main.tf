resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" # You can use "aws:kms" for KMS encryption
      }
    }
  }

  # Block all public access settings
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  tags = {
    Name        = var.name_tag
    Owner       = var.owner_tag
    Environment = var.environment_tag
  }
}  
  
}


# Name, environment, owner (many others)
# https://engineering.deptagency.com/best-practices-for-terraform-aws-tags

# Name, Environment, Owner, 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging
