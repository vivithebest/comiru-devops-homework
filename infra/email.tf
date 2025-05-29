data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_ses_domain_identity" "default" {
  domain = var.domain_name
}

resource "aws_route53_record" "ses_verification" {
  name    = aws_ses_domain_identity.default.verification_token
  zone_id = data.aws_route53_zone.selected.zone_id
  type    = "TXT"
  ttl     = 60
  records = [aws_ses_domain_identity.default.verification_token]
}

resource "aws_ses_domain_dkim" "default" {
  domain = aws_ses_domain_identity.default.domain
}

resource "aws_route53_record" "ses_dkim" {
  for_each = {
    # for idx, token in aws_ses_domain_dkim.default.dkim_tokens : idx => token
    for token in aws_ses_domain_dkim.default.dkim_tokens : token => token
  }

  name    = "${each.value}._domainkey.${aws_ses_domain_identity.default.domain}"
  zone_id = data.aws_route53_zone.selected.zone_id
  type    = "CNAME"
  ttl     = 60
  records = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "default" {
  domain           = aws_ses_domain_identity.default.domain
  mail_from_domain = "notification.${var.domain_name}"
}

# github action email iam
resource "aws_iam_user" "github_actions_ses" {
  name = "${var.project_name}-github-actions-ses"
  tags = {
    Project = var.project_name
    Purpose = "Allow GitHub Actions to send SES emails"
  }
}

resource "aws_iam_policy" "ses_send_policy" {
  name_prefix = "${var.project_name}-ses-send-policy-"
  description = "Allows sending emails via SES"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ses_send_attachment" {
  user       = aws_iam_user.github_actions_ses.name
  policy_arn = aws_iam_policy.ses_send_policy.arn
}

resource "aws_iam_access_key" "github_actions_ses" {
  user = aws_iam_user.github_actions_ses.name
}

output "github_actions_ses_iam_access_key" {
  value     = aws_iam_access_key.github_actions_ses.id
  sensitive = true
}

output "github_actions_ses_iam_secret_key" {
  value     = aws_iam_access_key.github_actions_ses.secret
  sensitive = true
}
