output "secret_arn" {
  value = aws_secretsmanager_secret.app.arn
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}
