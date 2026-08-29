resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.dns_zone_name
  tags  = var.tags
}

data "aws_route53_zone" "existing" {
  count = var.create_zone ? 0 : 1
  name  = var.dns_zone_name
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.dns_zone_name
  subject_alternative_names = ["*.${var.dns_zone_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# The ALB itself is created by the AWS Load Balancer Controller running
# in-cluster (Helm/Argo CD) when it sees an Ingress annotated with this
# certificate's ARN - same split as the Azure build: Terraform hands the
# cluster a validated cert and a zone, the cluster wires up the actual
# routing and DNS records for each service.
