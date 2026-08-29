resource "aws_secretsmanager_secret" "app" {
  name = "${var.name_prefix}/app-secrets"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({ placeholder = "replace-me-via-pipeline" })
}

# IRSA role that External Secrets Operator (or the app pod directly)
# assumes to read the secret above - scoped to one secret, one namespace,
# one service account, not "read all of Secrets Manager".
data "aws_iam_policy_document" "irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:apps:external-secrets"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.name_prefix}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "secrets_read" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.app.arn]
  }
}

resource "aws_iam_role_policy" "secrets_read" {
  name   = "secrets-read"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.secrets_read.json
}
