resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-acm-cert"
  }
}

locals {
  unique_records = zipmap(aws_acm_certificate.main.domain_validation_options.*.resource_record_name, tolist(aws_acm_certificate.main.domain_validation_options))
}

resource "aws_route53_record" "acm_validation" {
  for_each = local.unique_records

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 60
  records = [
    each.value.resource_record_value
  ]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
