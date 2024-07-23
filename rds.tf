# Username and passwor
# Credentials (username and password) are sensitive information and should never be stored in code
# AWS (and other cloud providers) provide a nice service for accessing this. Use it.
# get a random username and password from bash, and plug it into secrets manager before running this
# terraform code. The secret will be retrieved from AWS Secrets Manager using: "postgres-credentials"
# make sure to refer to the keys using "username" and "password"
#
# need to filter the characters in the password generated by openssl because:
#   Error: creating RDS DB Instance (terraform-20240717220022794200000001): InvalidParameterValue: The parameter MasterUserPassword is not
#   a valid password. Only printable ASCII characters besides '/', '@', '"', ' ' may be used.
# 
/*
    username="user_$(date +%s)"
    password=$(openssl rand -base64 20 | tr -dc 'a-zA-Z0-9')
    aws secretsmanager create-secret --name postgres-credentials --secret-string "{\"username\":\"$username\", \"password\":\"$password\"}"
*/


# Data source to fetch the secrets
data "aws_secretsmanager_secret" "postgres_credentials" {
  name = var.postgres_credentials_name
}

# Data source to fetch the secret version
data "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = data.aws_secretsmanager_secret.postgres_credentials.id
}


resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  #subnet_ids = data.aws_subnets.database_subnets.ids
  subnet_ids = aws_subnet.database_subnet[*].id

  tags = merge(
    var.tags,
    {
      Name = "PostgreSQL DB Subnet Group"
    }
  )  

}

# Resource to create the PostgreSQL RDS instance
/*
 table can be provisioned using application, or aws cli:
  aws rds execute-statement \
  --db-instance-identifier <instance_id> \
  --sql "CREATE TABLE contacts (
    _id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    zip VARCHAR(10)
 );"
*/
resource "aws_db_instance" "postgres_db" {
  db_name              = "${var.tags["Project"]}PGDB"
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = jsondecode(data.aws_secretsmanager_secret_version.postgres_credentials.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.postgres_credentials.secret_string)["password"]
  parameter_group_name = var.parameter_group_name
  db_subnet_group_name = aws_db_subnet_group.postgres_subnet_group.name
    
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  skip_final_snapshot    = true  # don't create final snapshot when destroying the DB
  publicly_accessible    = false # Ensure the DB is not publicly accessible

  tags = var.tags
}



resource "aws_security_group" "postgres_sg" {
  name        = "${var.tags["Project"]}-DB-SG"
  description = "Security group for Postgres RDS"
  vpc_id      = aws_vpc.this_vpc.id

  # Define ingress and egress rules as needed
  # For example:
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidr_blocks # only app servers in the private subnet are allowed to connect to DB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Output to display the connection details (optional)
output "postgres_connection" {
  value = aws_db_instance.postgres_db.endpoint
}

output "postgres_instance_id" {
  description = "The database instance ID"
  value       = aws_db_instance.postgres_db.id
}