resource "null_resource" "run-ansible" {

  # Makes sure ansible runs after all resources are available
  depends_on = [google_compute_instance.server,google_compute_disk.disk,google_compute_firewall.administration]

  provisioner "local-exec" {
    command = data.template_file.ansible-install.rendered
  }
}

output "ece-ui-url" {
  value = format("https://%s:12443", google_compute_instance.server[0].network_interface[0].access_config[0].nat_ip)
}

output "ece-api-url" {
  value = format("https://%s:12343",google_compute_instance.server[0].network_interface[0].access_config[0].nat_ip)
}

output "ece-instances" {
  description = "The public ip of the created server instances."
  value = [google_compute_instance.server[*].network_interface[0].access_config[0].nat_ip]
}