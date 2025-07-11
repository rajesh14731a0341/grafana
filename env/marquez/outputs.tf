output "marquez_api_url" {
  value = "http://${module.marquez_stack.alb_dns}/marquez/api"
}

output "marquez_web_url" {
  value = "http://${module.marquez_stack.alb_dns}/marquez/web"
}
