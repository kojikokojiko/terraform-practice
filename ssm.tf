resource "aws_ssm_parameter" "db_username" {

  name = "/db/username"
  value = "root"
  type = "String"
  description = "DB username"
}
resource "aws_ssm_parameter" "db_password" {

  name = "/db/password2"
  value = "VerySecretPassword"
  type = "SecureString"
  description = "DB password"
  lifecycle {
    ignore_changes = [value]
  }
  overwrite = true
}


