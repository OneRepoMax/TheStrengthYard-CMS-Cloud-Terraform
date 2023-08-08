resource "aws_iam_role" "codepipeline_codedeploy_role" {
  name = "tap_gig_codepipeline_codedeploy_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codepipeline_policy_attachment" {
  name       = "MyCodePipelinePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  roles      = [aws_iam_role.codepipeline_codedeploy_role.name]
}

resource "aws_iam_policy_attachment" "codedeploy_policy_attachment" {
  name       = "MyCodeDeployPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
  roles      = [aws_iam_role.codepipeline_codedeploy_role.name]
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "MyS3PolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.codepipeline_codedeploy_role.name]
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "MyCodeBuildPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  roles      = [aws_iam_role.codepipeline_codedeploy_role.name]
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.codepipeline_codedeploy_role.name
}

resource "aws_iam_role_policy_attachment" "elastic_beanstalk_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
  role       = aws_iam_role.codepipeline_codedeploy_role.name
}