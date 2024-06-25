/*
EC2 Instance and Security Group Configuration

This Terraform configuration creates an EC2 instance in a public subnet of the VPC.
It also defines a security group to control inbound and outbound traffic for the EC2 instance. 

Resources created:
    Security Group: Allows SSH access from specified subnets and unrestricted outbound traffic.
    SSH Key Pair: An ED25519 SSH key pair is used for secure access to the EC2 instance.
    EC2 Instance: The instance is launched in the public subnet of the specified Availability Zone.

This setup enables:

    Secure access to the EC2 instance using SSH.
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
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_subnets  # Allow traffic from allowed subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
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
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbUFKGxzkTOWswo7TSw3PVu8C6HvJHuDYlmBSHVu0Wu your_email@example.com"

}


# find the public subnet which was provisioned in the AZ specified in `ec2_availability_zone`
data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["pub-subnet-${var.ec2_availability_zone}"]
  }
}

# Create an EC2 instance in the Public Subnet/AZ specified in `ec2_availability_zone`
resource "aws_instance" "this_ec2_instance" {
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = data.aws_subnet.selected.id
  security_groups   = [aws_security_group.ec2_sg.id]
  availability_zone = var.ec2_availability_zone       # make sure to use the same AZ as in public_subnet[0]
  key_name          = aws_key_pair.this_key_pair.key_name
  tags              = var.tags
}

# Output the public IP address of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this_ec2_instance.public_ip
}