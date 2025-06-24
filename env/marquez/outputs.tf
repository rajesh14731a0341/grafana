output "marquez_api_url" {
  value = "http://${module.marquez.public_alb_dns}/marquez/api"
}

output "marquez_web_url" {
  value = "http://${module.marquez.public_alb_dns}/marquez"
}
