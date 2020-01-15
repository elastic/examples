provider "aws" {
  region  = "${var.region}"

  # You can uncomment this to use simple access/secret keys instead
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"

  # Comment this out if you'd like to use access/secret keys
  profile = "${var.profile}"
}

terraform {
  required_version = "0.11.14"
}