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
    name      = "DB_HOSTNAME"
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
    name      = "DB_USERNAME"
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