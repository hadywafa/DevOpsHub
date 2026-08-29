output "zone_id" {
  value = local.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "name_servers" {
  value = var.create_zone ? aws_route53_zone.this[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}
