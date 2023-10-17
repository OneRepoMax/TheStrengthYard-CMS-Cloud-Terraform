provider "aws" {
  region = "ap-southeast-1"
}

# Creating VPC, IGW
resource "aws_vpc" "tsy-iabs-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TSY-IABS-VPC"
  }
}

resource "aws_internet_gateway" "tsy_iabs_igw" {
  vpc_id = aws_vpc.tsy-iabs-vpc.id
  tags = {
    Name = "TSY-IABS-Internet-Gateway"
  }
}

# Creating NAT Gateways and Elastic IPs for each subnet
resource "aws_nat_gateway" "tsy_iabs_nat_a" {
  allocation_id = aws_eip.tsy_iabs_nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "TSY-IABS-NAT-Gateway-a"
  }
}

resource "aws_nat_gateway" "tsy_iabs_nat_b" {
  allocation_id = aws_eip.tsy_iabs_nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "TSY-IABS-NAT-Gateway-b"
  }
}

resource "aws_eip" "tsy_iabs_nat_a" {
  vpc = true
}

resource "aws_eip" "tsy_iabs_nat_b" {
  vpc = true
}

# Creating 2x public subnets, 1 for each AZ
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.tsy-iabs-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "TSY-IABS-Public-Subnet-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.tsy-iabs-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "TSY-IABS-Public-Subnet-1b"
  }
}

# Creating 2x private subnets, 1 for each AZ
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.tsy-iabs-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "TSY-IABS-Private-Subnet-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.tsy-iabs-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "TSY-IABS-Private-Subnet-1b"
  }
}

# Creating Public Route Table with Associations to Public Subnets
resource "aws_route_table" "tsy_iabs_route_table_public" {
  vpc_id = aws_vpc.tsy-iabs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tsy_iabs_igw.id
  }

  tags = {
    Name = "tsy-iabs-route-table-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.tsy_iabs_route_table_public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.tsy_iabs_route_table_public.id
}

# Creating Private Route Table A for Subnet A
resource "aws_route_table" "tsy_iabs_route_table_private_a" {
  vpc_id = aws_vpc.tsy-iabs-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tsy_iabs_nat_a.id
  }

  tags = {
    Name = "tsy-iabs-route-table-private-a"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.tsy_iabs_route_table_private_a.id
}

# Creating Private Route Table B for Subnet B
resource "aws_route_table" "tsy_iabs_route_table_private_b" {
  vpc_id = aws_vpc.tsy-iabs-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tsy_iabs_nat_b.id
  }

  tags = {
    Name = "tsy-iabs-route-table-private-b"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.tsy_iabs_route_table_private_b.id
}

# Creating Security Group for EC2 instances
resource "aws_security_group" "instance" {
  name_prefix = "tsy-iabs-instance-"
  vpc_id      = aws_vpc.tsy-iabs-vpc.id

  # Ingress rules for allowing RDP and HTTP access from anywhere
  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
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
  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
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
  name_prefix = "tsy-iabs-elb-"
  vpc_id      = aws_vpc.tsy-iabs-vpc.id

  # Add inbound rules to allow traffic on port 80 and other necessary ports
  # You can customize the security group rules based on your application requirements.

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
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

# Creating Instance Profile
resource "aws_iam_instance_profile" "tsy_iabs_instance_profile" {
  name = "tsy-iabs-instance-profile"
  role = aws_iam_role.codepipeline_codedeploy_role.id
}

# Creating ACM Certificate for HTTPS
resource "aws_acm_certificate" "tsy_iabs_certificate" {
  domain_name       = "tsy-iabs.online"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


# Creating RDS Subnet Group
resource "aws_db_subnet_group" "tsy_iabs_db_subnet_group" {
  name       = "tsy-iabs-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

# Creating RDS Instance
resource "aws_db_instance" "tsy_iabs_db_instance" {
  identifier            = "tsy-iabs-db-instance"
  allocated_storage    = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t3.micro"
  name                  = "tsy_db"
  username              = "admin"
  password              = var.db_password
  publicly_accessible  = true
  multi_az              = true
  skip_final_snapshot   = true

  vpc_security_group_ids = [aws_security_group.instance.id]
  db_subnet_group_name   = aws_db_subnet_group.tsy_iabs_db_subnet_group.name

  backup_retention_period = 7
  monitoring_interval = 60
  max_allocated_storage = 40

  tags = {
    Name = "tsy-iabs-db-instance"
  }
}

# Defining the Elastic Beanstalk TSY-IABS Application
resource "aws_elastic_beanstalk_application" "tsy_iabs_app" {
  name        = "tsy-iabs-be-app"
  description = "TSY-IABS TheStrengthYard-CMS-Service Application"
}

# # Defining the Elastic Beanstalk TSY-IABS Environment
resource "aws_elastic_beanstalk_environment" "tsy_iabs_env" {
  name                = "tsy-iabs-env"
  application         = aws_elastic_beanstalk_application.tsy_iabs_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker"

  # Configuring Elastic Beanstalk env with necessary settings
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.tsy-iabs-vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", 
    [aws_subnet.private_a.id], 
    [aws_subnet.private_b.id])}"
  }

  # Pass RDS connection details to Elastic Beanstalk environment
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = aws_db_instance.tsy_iabs_db_instance.endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT"
    value     = aws_db_instance.tsy_iabs_db_instance.port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_NAME"
    value     = aws_db_instance.tsy_iabs_db_instance.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USER"
    value     = aws_db_instance.tsy_iabs_db_instance.username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASSWORD"
    value     = aws_db_instance.tsy_iabs_db_instance.password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SECURITY_PASSWORD_SALT"
    value     = jsondecode(data.aws_secretsmanager_secret_version.email_secrets.secret_string)["SECURITY_PASSWORD_SALT"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EMAIL_USER"
    value     = jsondecode(data.aws_secretsmanager_secret_version.email_secrets.secret_string)["EMAIL_USER"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EMAIL_PASSWORD"
    value     = jsondecode(data.aws_secretsmanager_secret_version.email_secrets.secret_string)["EMAIL_PASSWORD"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PAYPAL_CLIENT_ID"
    value     = jsondecode(data.aws_secretsmanager_secret_version.paypal_secrets.secret_string)["PAYPAL_CLIENT_ID"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PAYPAL_CLIENT_SECRET"
    value     = jsondecode(data.aws_secretsmanager_secret_version.paypal_secrets.secret_string)["PAYPAL_CLIENT_SECRET"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OPENAI_API_KEY"
    value     = jsondecode(data.aws_secretsmanager_secret_version.chatbot_secrets.secret_string)["OPENAI_API_KEY"]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LANGCHAIN_API_KEY"
    value     = jsondecode(data.aws_secretsmanager_secret_version.chatbot_secrets.secret_string)["LANGCHAIN_API_KEY"]
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.tsy_iabs_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.instance.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "tsy-iabs-keypair"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "classic"
  }

  # Turn on Listener for HTTPS
  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }

  # Configure ACM Certificate for HTTPS
  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = aws_acm_certificate.tsy_iabs_certificate.arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"  # Enable cross-zone load balancing
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ])
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.elb.id
  }
}