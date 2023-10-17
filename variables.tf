# variable "github_token" {
#   description = "GitHub personal access token for CodePipeline"
#   type        = string
# }

variable "acl_value" {
    default = "private"
}

variable "db_password" {
  description = "value of the db password"
  type        = string
}