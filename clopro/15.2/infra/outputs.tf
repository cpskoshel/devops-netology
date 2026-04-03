output "nlb_ip_address" {
  description = "Public IP address of the Network Load Balancer"
  value = yandex_lb_network_load_balancer.nlb.listener[*].external_address_spec[*].address
}

output "alb_ip_address" {
  description = "Public IP address of the Application Load Balancer"
  value = yandex_alb_load_balancer.alb.listener[*].endpoint[*].address[*].external_ipv4_address[*].address
}

output "picture_url" {
  description = "URL of the uploaded image in Object Storage"
  value = "https://${yandex_storage_bucket.nuke-bucket.bucket_domain_name}/${yandex_storage_object.nuke-pic.key}"
}

