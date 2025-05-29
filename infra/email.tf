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
