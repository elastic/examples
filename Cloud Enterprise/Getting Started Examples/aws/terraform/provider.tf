provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

terraform {
  required_version = "0.11.14"
}