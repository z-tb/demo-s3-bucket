
locals {
  # used in multiple places - for lambda function and cloudwatch log group
  lambda_function_name = "${var.tags.Name}-LAMBDA"
}

# define the path to the zip file that contains the lambda function
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = var.lambda_output_path
}


# Define the CloudWatch Log Group with retention policy to something reasonable to manage storage costs
resource "aws_cloudwatch_log_group" "lambda_logs" {

  # the name of the log group is created by lambda and always uses the name of the lambda function.
  # if you want to set retention, you have to use the log group name geneated by AWS
  # https://stackoverflow.com/a/59060348
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.log_retention_in_days  # Set retention policy to something reasonable

  tags = var.tags
}


# re-zip the file if changed
resource "null_resource" "generate_lambda_zip" {
  triggers = {
    source_file_hash = filebase64sha256("${var.lambda_source_dir}/${var.tags.Name}.py")
  }

  provisioner "local-exec" {
    command = "cd ${var.lambda_source_dir} && zip -r ../../${var.lambda_output_path} ${var.tags.Name}.py"
  }
}


# Define the Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  # Use the ZIP file created by the archive_file data source
  description       = var.lambda_description
  filename          = data.archive_file.lambda_function_zip.output_path
  function_name     = local.lambda_function_name
  role              = aws_iam_role.lambda_role.arn
  handler           = "${var.tags.Name}.lambda_handler"
  source_code_hash  = data.archive_file.lambda_function_zip.output_base64sha256  #<-- monitor the source python script for changes
  runtime           = var.lambda_runtime 

  # Make sure the log group (and IAM role?) has been created first, or you'll get two -- one you want, and the other is a default
  depends_on = [
    aws_iam_role.lambda_role,
    aws_cloudwatch_log_group.lambda_logs
  ]

   # supply the name of the parameter store/secrets manager keys to the lambda function
  environment {
    variables = {
      S3_BUCKET_NAME      = "${var.bucket_name}"
    }
  }

  # add some handy tags
  tags = var.tags
}



# Define the Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name = "${var.tags.Name}-LAM-ROLE"

  # Allow Lambda to use AssumeRole
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Attach a policy that allows writing to CloudWatch Logs
  # https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/lambda_function
  inline_policy {
    name = "${var.tags.Name}-LOG-POL"

    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Action   = ["logs:CreateLogGroup", 
                      "logs:CreateLogStream",
                      "logs:PutLogEvents"],
          Effect   = "Allow",
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
    })
  }

  # add an inline policy that allows listing all s3 buckets and reading/writing to the specific var.bucket_name bucket
  inline_policy {
    name = "${var.tags.Name}-S3-POL"

    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Action   = ["S3:ListAllMyBuckets"]

          Effect   = "Allow",
          Resource = ["arn:aws:s3:::*"]
        },
        {
          Action   = ["s3:GetBucketLocation",
                      "s3:ListBucket",
                      "S3:ListAllMyBuckets",
                      "s3:ListBucketMultipartUploads",
                      "s3:ListMultipartUploadParts",
                      "s3:PutObject",
                      "s3:GetObject",
                      "s3:DeleteObject",
                      "s3:AbortMultipartUpload"],
          Effect   = "Allow",
          Resource = ["arn:aws:s3:::${var.bucket_name}",
                      "arn:aws:s3:::${var.bucket_name}/*"]
        }
      ]
    })
  }

  /* # Allow access to the specified Secrets Manager secret
  # follow Resource with "*" because the ARN for the secret has a few AWS generated characters after the actual name
  inline_policy {
    name = "${var.tags.Name}-SM-POL"

    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Action   = "secretsmanager:GetSecretValue",
          Effect   = "Allow",
          Resource = "${local.slack_secret_arn}*"
        }
      ]
    })
  } */

  
  /* # Allow access to SSM Parameter Store with a specific prefix
  inline_policy {
    name = "${var.tags.Name}-SSM-POL"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
          Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"],
          Effect   = "Allow",
          Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*",
        },
      ]
    })
  } */
  

  /* # Cost Usage/Explorer
  # Resource needs to be "*" here as that is all that is allowed in the policy editor
  inline_policy {
    name = "${var.tags.Name}-CE-POL"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action   = ["ce:GetCostAndUsage", "ce:GetCostForecast"],
          Effect   = "Allow",
          Resource = "*",
        },
      ]
    })
  } */
    

  tags = var.tags
}


resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name                = "${var.tags.Name}-CW-RULE"
  description         = "Rule to schedule a Lambda function"
  schedule_expression = "rate(5 minutes)"
  

  // Optional: Uncomment the following block if you want to filter events
  # event_pattern = <<PATTERN
  # {
  #   "source": ["aws.ec2"],
  #   "detail": {
  #     "eventName": ["RunInstances"]
  #   }
  # }
  # PATTERN
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.my_lambda_function.arn


  // Optional: Uncomment the following block if you want to pass custom parameters to Lambda
  input = jsonencode(
    {
      Message    = "CloudWatch Launch!"
      Name       = var.tags.Name
      BucketName = var.bucket_name
    })
  

  #notags
}

# needed to allow CloudWatch Events to call the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
  
  #notags
}
