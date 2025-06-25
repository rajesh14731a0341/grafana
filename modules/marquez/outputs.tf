output "public_alb_dns" {
  value = data.aws_lb.public_alb.dns_name
}

output "internal_nlb_dns" {
  value = data.aws_lb.internal_nlb.dns_name
}
