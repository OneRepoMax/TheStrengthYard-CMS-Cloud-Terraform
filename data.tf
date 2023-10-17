# data.tf
data "aws_secretsmanager_secret_version" "paypal_secrets" {
  secret_id = "tsy-iabs/paypal"
}

data "aws_secretsmanager_secret_version" "email_secrets" {
  secret_id = "tsy-iabs/emailsecret"
}

data "aws_secretsmanager_secret_version" "chatbot_secrets" {
  secret_id = "tsy-iabs/chatbot"
}