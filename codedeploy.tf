# # Creating CodeDeploy Application and Deployment Group
# resource "aws_codedeploy_app" "tap_gig_cd_app" {
#   name = "tap-gig-codedeploy-app"
# }

# resource "aws_codedeploy_deployment_group" "tap_gig_cd_deployment_group" {
#   app_name            = aws_codedeploy_app.tap_gig_cd_app.name
#   deployment_config_name = "CodeDeployDefault.OneAtATime"  # Replace with desired deployment configuration
#   deployment_group_name = "tap-gig-codedeploy-deployment-group"
#   service_role_arn    = aws_iam_role.codepipeline_codedeploy_role.arn

#   auto_rollback_configuration {
#     enabled = true
#     events  = ["DEPLOYMENT_FAILURE"]
#   }
#   ec2_tag_set {
#     ec2_tag_filter {
#       key = "Name"
#       type = "KEY_AND_VALUE"
#       value = "tap-gig-asg"
#     }
#   }
# }