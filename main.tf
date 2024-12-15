/* 
This terraform code provisions a Lambda, S3 bucket, and 
Cloudwatch Event Trigger which runs the Lambda every 5 mins

   ┌────────┐              ┌─────────┐   
   │        │              │         │   
   │ LAMBDA │   FILE       │S3 BUCKET│   
   │        ├─────────────►│         │   
   │        │              │         │   
   └──┬─────┘              └─────────┘   
      │                                  
      │                                  
      │                                  
   ┌──┴────────┐                         
   │5 MIN      │                         
   │CLOUDWATCH │                         
   │EVENT      │                         
   │TRIGGER    │                         
   └───────────┘ 
*/

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags = var.tags
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


locals {
  # used in multiple places - for lambda function and cloudwatch log group
  lambda_function_name = "${var.tags.Name}-LAMBDA"
  ec2_availability_zone = "${var.aws_region}c"
  availability_zones = [for suffix in ["a", "b", "c"] : "${var.aws_region}${suffix}"]
}
