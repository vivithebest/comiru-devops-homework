output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.main.repository_url
}

output "github_actions_ses_iam_access_key" {
  value     = aws_iam_access_key.github_actions_ses.id
  sensitive = true
}

output "github_actions_ses_iam_secret_key" {
  value     = aws_iam_access_key.github_actions_ses.secret
  sensitive = true
}
