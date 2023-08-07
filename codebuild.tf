# resource "aws_codebuild_project" "tap_gig_codebuild_project" {
#   name        = "TAP-GIG-CodeBuild-Project" # Replace with your project name
#   description = "TAP-GIG-CodeBuild-Project"  
#   service_role = aws_iam_role.codepipeline_codedeploy_role.arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type = "BUILD_GENERAL1_MEDIUM"
#     image        = "aws/codebuild/windows-base:2019-1.0"  # Use Windows Server 2019 base image
#     type         = "WINDOWS_SERVER_2019_CONTAINER"  # Use Windows Server 2019 environment
#   }

#   source {
#     type = "CODEPIPELINE"
#   }
# }
