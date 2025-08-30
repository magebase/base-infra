# Check if GitHub Actions SSO role exists
data "aws_iam_role" "github_actions_sso_existing" {
  name = "GitHubActionsSSORole"
}

# GitHub Actions SSO Role for Infrastructure Management
resource "aws_iam_role" "github_actions_sso" {
  count = length(data.aws_iam_role.github_actions_sso_existing) == 0 ? 1 : 0

  name = "GitHubActionsSSORole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:magebase/site:*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "Management"
    Purpose     = "GitHub Actions SSO"
    ManagedBy   = "terraform"
  }
}

# Attach AdministratorAccess policy for full infrastructure management
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  count = length(aws_iam_role.github_actions_sso) > 0 ? 1 : 0

  role       = aws_iam_role.github_actions_sso[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
