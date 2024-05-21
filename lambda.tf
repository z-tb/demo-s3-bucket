

# define the path to the zip file that contains the lambda function
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = var.lambda_output_path
}


# Define the CloudWatch Log Group with retention policy to something reasonable to manage storage costs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "${var.name_tag}-LOGS"
  retention_in_days = var.log_retention_in_days  # Set retention policy to something reasonable

  tags = {
    Name        = var.name_tag
    Owner       = var.owner_tag
    Environment = var.environment_tag
  }
}


# re-zip the file if changed
resource "null_resource" "generate_lambda_zip" {
  triggers = {
    source_file_hash = filebase64sha256("${var.lambda_source_dir}/${var.lambda_filename}")
  }

  provisioner "local-exec" {
    command = "cd ${var.lambda_source_dir} && zip -r ../../${var.lambda_output_path} ${var.lambda_filename}"
  }
}


# Define the Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  # Use the ZIP file created by the archive_file data source
  description       = "Runs periodically via CloudWatch to monitor costs. Sends alerts via Slack. Configurable threshold is in ParameterStore"
  filename          = data.archive_file.lambda_function_zip.output_path
  function_name     = "${var.name_tag}-LAMDA"
  role              = aws_iam_role.lambda_role.arn
  handler           = "${var.name_tag}.lambda_handler"
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
  tags = {
    Name        = var.name_tag
    Owner       = var.owner_tag
    Environment = var.environment_tag
  }
}



# Define the Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name = "${var.name_tag}-LAM-ROLE"

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
    name = "${var.name_tag}-CW-POL"

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

  /* # Allow access to the specified Secrets Manager secret
  # follow Resource with "*" because the ARN for the secret has a few AWS generated characters after the actual name
  inline_policy {
    name = "${var.name_tag}-SM-POL"

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
    name = "${var.name_tag}-SSM-POL"

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
    name = "${var.name_tag}-CE-POL"

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
    

  tags = {
    Name        = var.name_tag
    Owner       = var.owner_tag
    Environment = var.environment_tag
  }
}
