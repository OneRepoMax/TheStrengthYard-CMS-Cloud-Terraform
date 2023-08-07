provider "aws" {
  region = "ap-southeast-1"
}

# Creating VPC, IGW, Subnets, and Security Groups
resource "aws_vpc" "tap_gig_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tap-gig-vpc"
  }
}

resource "aws_internet_gateway" "tap_gig_igw" {
  vpc_id = aws_vpc.tap_gig_vpc.id
}

# Creating 3x public subnets, 1 for each AZ
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "TAP-GIG-Public-Subnet-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "TAP-GIG-Public-Subnet-1b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "TAP-GIG-Public-Subnet-1c"
  }
}

# Creating 3x private subnets, 1 for each AZ
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "TAP-GIG-Private-Subnet-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "TAP-GIG-Private-Subnet-1b"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.tap_gig_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "TAP-GIG-Private-Subnet-1c"
  }
}

# Creating Public Route Table with Associations to Public Subnets
resource "aws_route_table" "tap_gig_route_table_public" {
  vpc_id = aws_vpc.tap_gig_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tap_gig_igw.id
  }

  tags = {
    Name = "tap-gig-route-table-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.tap_gig_route_table_public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.tap_gig_route_table_public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.tap_gig_route_table_public.id
}

# Creating Private Route Table with 3x Associations to Private Subnets
resource "aws_route_table" "tap_gig_route_table_private" {
  vpc_id = aws_vpc.tap_gig_vpc.id

  tags = {
    Name = "tap-gig-route-table-private"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.tap_gig_route_table_private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.tap_gig_route_table_private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.tap_gig_route_table_private.id
}

# Creating Security Group for EC2 instances
resource "aws_security_group" "instance" {
  name_prefix = "tap-gig-instance-"
  vpc_id      = aws_vpc.tap_gig_vpc.id

  # Ingress rules for allowing SSH and HTTP access from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all traffic to go anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name_prefix = "tap-gig-elb-"
  vpc_id      = aws_vpc.tap_gig_vpc.id

  # Add inbound rules to allow traffic on port 80 and other necessary ports
  # You can customize the security group rules based on your application requirements.

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating ELB
resource "aws_elb" "tap_gig_elb" {
  name               = "tap-gig-elb"
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id
    ]
  security_groups    = [aws_security_group.elb.id]
  cross_zone_load_balancing  = true
  idle_timeout       = 400
  connection_draining = true
  connection_draining_timeout = 300
  tags = {
    Name = "tap-gig-elb"
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

# Creating EC2 Launch Configuration and ASG
resource "aws_launch_configuration" "tap_gig_lc" {
  name_prefix                 = "tap-gig-lc"
  image_id                    = "ami-0a720e9f14071b468"  # Microsoft Windows Server 2019 Base
  instance_type               = "t2.micro"  # Replace with your desired instance type
  security_groups             = [aws_security_group.instance.id]
  associate_public_ip_address = false
  key_name                    = "tap-gig-keypair"  # Replace with your EC2 key pair name
  user_data                   = file("install.sh")  # Replace with your user data script, if any

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                 = "tap-gig-asg"
  launch_configuration = aws_launch_configuration.tap_gig_lc.name
  min_size             = 2  # Replace with your desired minimum number of instances
  max_size             = 4  # Replace with your desired maximum number of instances
  desired_capacity     = 2  # Replace with your desired initial number of instances
  vpc_zone_identifier  = [
    aws_subnet.private_a.id, 
    aws_subnet.private_b.id, 
    aws_subnet.private_c.id
    ]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.tap_gig_elb.name]
  tags = [
    {
      key                 = "Name"
      value               = "tap-gig-asg"
      propagate_at_launch = true
    }
  ]
}
