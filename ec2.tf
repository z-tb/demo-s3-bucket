/*
EC2 Instance and Security Group Configuration

This Terraform configuration creates an EC2 instance in a public subnet of the VPC.
It also defines a security group to control inbound and outbound traffic for the EC2 instance. 

Resources created:
    Security Group: Allows SSH access from specified subnets and unrestricted outbound traffic.
    SSH Key Pair: An ED25519 SSH key pair is used for secure access to the EC2 instance.
    EC2 Instance: The instance is launched in the public subnet of the specified Availability Zone.
    SSM configuration: The EC2 instances are also configured to use SSM which allows for remote managment without exposing ssh to the internet.


This setup enables:
    Secure access to the EC2 instance using SSH or SSM
    Controlled inbound traffic based on allowed subnets.
    Unrestricted outbound traffic for the EC2 instance.

To ensure that the EC2 instance is launched in the same Availability Zone (AZ) as the specified public subnet, 
the aws_subnet data source is used to find the correct subnet based on the ec2_availability_zone variable.
This is a little complicated, but keeps the configuration automatic and hinged on the availability zone rather
than hardcoded arrays.

Note: look over the ssh key pair resource below. create a new PEM and paste in the public key.
Note: Ensure that the variables used in this configuration are properly defined in your variables file.
Note: This configuration assumes that a VPC, Internet Gateway, and public subnets have already been created 
      using Terraform. The EC2 instance will be launched in one of the existing public subnets.
*/

# Create a Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.this_vpc.id

  # Ingress rules allowing traffic from specified subnets
  # using SSM so this is not needed and more importantly, does not expose ssh to the internet
  /*
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_subnets  # Allow traffic from allowed subnets
  }*/

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# private subnet ec2 for DB access
resource "aws_security_group" "private_ec2_sg" {
  vpc_id = aws_vpc.this_vpc.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {Name = "private-ec2-sg"})
}


# Create an EC2 instance in the Public Subnet
# generate an ssh keypair:
#   ssh-keygen -t ed25519 -f ~/.ssh/my_ec2_deleteme_key -C "your_email@example.com"
# them make a PEM for the EC2:
#   ssh-keygen -p -m PEM -f ~/.ssh/my_ec2_deleteme_key
# add the pub key text below:
#   cat ~/.ssh/my_ec2_deleteme_key.pub 

resource "aws_key_pair" "this_key_pair" {
  key_name   = "my-ec2-key"
  public_key = var.ec2_ssh_public_key

}


# find the public subnet which was provisioned in the AZ specified in `ec2_availability_zone`
data "aws_subnet" "public_sub" {
  filter {
    name   = "tag:Name"
    values = ["pub-subnet-${var.ec2_availability_zone}"]
  }

  depends_on = [ aws_subnet.public_subnet ]
}

# find the private subnet which was provisioned in the AZ specified in `ec2_availability_zone`
data "aws_subnet" "private_sub" {
  filter {
    name   = "tag:Name"
    values = ["priv-subnet-${var.ec2_availability_zone}"]
  }

  depends_on = [aws_subnet.private_subnet]
}

# Create an EC2 instance in the Public Subnet/AZ specified in `ec2_availability_zone`
resource "aws_instance" "this_ec2_instance" {
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = data.aws_subnet.public_sub.id
  security_groups   = [aws_security_group.ec2_sg.id]
  availability_zone = var.ec2_availability_zone
  key_name          = aws_key_pair.this_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  
  tags              = var.tags
}

# create the private ec2
resource "aws_instance" "private_ec2_instance" {
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = data.aws_subnet.private_sub.id
  security_groups   = [aws_security_group.private_ec2_sg.id]
  availability_zone = var.ec2_availability_zone
  key_name          = aws_key_pair.this_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags              = merge(var.tags, {Name = "private-ec2-instance"})
}



# SSM for connectivity
# curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
resource "aws_iam_role" "ssm_role" {
  name = "SSMInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}


resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.this_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id,
  ]

  private_dns_enabled = true
  subnet_ids          = [data.aws_subnet.private_sub.id]

  tags = merge(var.tags, {Name = "ssm-endpoint"})
}

# SSMMESSAGES between EC2 and SSM api
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.this_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id,
  ]

  private_dns_enabled = true
  subnet_ids          = [data.aws_subnet.private_sub.id]

  tags = merge(var.tags, {Name = "ssmmessages-endpoint"})
}


resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.this_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_endpoint_sg.id,
  ]

  private_dns_enabled = true
  subnet_ids          = [data.aws_subnet.private_sub.id]

  tags = merge(var.tags, {Name = "ec2messages-endpoint"})
}


# security group for SSM
resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "ssm-endpoint-sg"
  description = "Allow inbound traffic for SSM VPC Endpoints"
  vpc_id      = aws_vpc.this_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this_vpc.cidr_block]
  }

  tags = merge(var.tags, {Name = "ssm-endpoint-sg"})
}

# output instance ID of public ec2
output "public_instance_id" {
  value = aws_instance.this_ec2_instance.id
}

# output instance ID of private ec2
output "private_instance_id" {
  value = aws_instance.private_ec2_instance.id
}

# Output the public IP address of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this_ec2_instance.public_ip
}

# private ec2 IP address
output "private_instance_ip" {
  description = "Private IP address of the EC2 instance in the private subnet"
  value       = aws_instance.private_ec2_instance.private_ip
}

