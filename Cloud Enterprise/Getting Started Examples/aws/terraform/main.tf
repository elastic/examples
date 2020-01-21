terraform {
  required_version >= 0.12
}

# Initiate ece installation through ansible playbook
resource "null_resource" "run-ansible" {
  provisioner "local-exec" {
    command = data.template_file.ansible-install.rendered
  }
}

output "ece-instances" {
   description = "The public dns of created server instances."
   value = [aws_instance.server.*.public_dns]
}

output "ece-ui-url" {
   value = format("https://%s:12443",aws_instance.server.0.public_dns)
}

output "ece-api-url" {
   value = format("https://%s:12343",aws_instance.server.0.public_dns)
}
