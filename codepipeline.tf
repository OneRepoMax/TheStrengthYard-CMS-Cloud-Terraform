# Creating CodePipeline and S3 bucket for artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "tap-gig-codepipeline-artifacts-bucket" 
  tags = {
    Name = "tap-gig-codepipeline-artifacts-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_artifacts" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_artifacts]

  bucket = aws_s3_bucket.codepipeline_artifacts.id
  acl    = "private"
}

# Creating CodePipeline
resource "aws_codepipeline" "tap_gig_codepipeline" {
  name     = "tap-gig-codepipeline"
  role_arn = aws_iam_role.codepipeline_codedeploy_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "SourceAction"
      category        = "Source"
      owner           = "ThirdParty"
      provider        = "GitHub"
      version         = "1"
      output_artifacts = ["SourceOutput"]

    # Please change the below Github configurations accordingly
      configuration = {
        Owner             = "mukminpitoyo"
        Repo              = "BeanstalkDotNetSample"
        Branch            = "main"
        OAuthToken        = var.github_token  # Define the GitHub token as a variable
      }
    }
  }

  # stage {
  #   name = "Build"

  #   action {
  #     name            = "BuildAction"
  #     category        = "Build"
  #     owner           = "AWS"
  #     provider        = "CodeBuild"
  #     version         = "1"
  #     input_artifacts = ["SourceOutput"]

  #     configuration = {
  #       ProjectName = aws_codebuild_project.tap_gig_codebuild_project.name  # Replace with your CodeBuild project name
  #     }
  #   }
  # }

 stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk" # Replace with "CodeDeploy" if you want to use CodeDeploy
      version         = "1"
      input_artifacts = ["SourceOutput"]


      # configuration = {
      #     ApplicationName     = aws_codedeploy_app.tap_gig_cd_app.name
      #     DeploymentGroupName = aws_codedeploy_deployment_group.tap_gig_cd_deployment_group.deployment_group_name 
      # }
      configuration = {
        ApplicationName  = aws_elastic_beanstalk_application.tap_gig_app.name
        EnvironmentName  = aws_elastic_beanstalk_environment.tap_gig_env.name
      }
    }
  } 
}
