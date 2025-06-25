output "public_alb_dns" {
  value = module.marquez.public_alb_dns
}

output "internal_nlb_dns" {
  value = module.marquez.internal_nlb_dns
}
