data "aws_caller_identity" "current" {}

resource "aws_iam_user" "github_deploy" {
  name = "${var.project_name}-github-deploy"
}

resource "aws_iam_user_policy" "github_deploy" {
  name = "${var.project_name}-ssm-deploy"
  user = aws_iam_user.github_deploy.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RunDeploymentOnApplicationInstance"
        Effect = "Allow"
        Action = "ssm:SendCommand"
        Resource = [
          "arn:aws:ssm:eu-north-1::document/AWS-RunShellScript",
          "arn:aws:ec2:eu-north-1:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.app.id}"
        ]
      },
      {
        Sid      = "ReadCommandResult"
        Effect   = "Allow"
        Action   = "ssm:GetCommandInvocation"
        Resource = "*"
      }
    ]
  })
}
