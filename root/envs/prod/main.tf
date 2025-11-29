# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "pathology-lab-vpc"
  }
}

# Private Subnet 1 (ap-south-1a)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "pathology-lab-private-subnet-1a"
  }
}

# Private Subnet 2 (ap-south-1b)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "pathology-lab-private-subnet-1b"
  }
}

# Launch Template for RHEL EC2 instances
resource "aws_launch_template" "rhel" {
  name_prefix            = "pathology-lab-rhel-"
  image_id               = data.aws_ami.rhel.id
  instance_type          = "t4g.small"
  vpc_security_group_ids = [aws_security_group.rhel.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "pathology-lab-rhel-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for RHEL instances
resource "aws_security_group" "rhel" {
  name_prefix = "pathology-lab-rhel-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pathology-lab-rhel-sg"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "rhel" {
  name                = "pathology-lab-rhel-asg"
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.rhel.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "pathology-lab-rhel-asg-instance"
    propagate_at_launch = true
  }
}

# Data source for latest RHEL AMI
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}