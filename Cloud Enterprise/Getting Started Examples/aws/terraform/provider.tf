provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
  version = "1.3.0"
}

provider "template" {
  version = "1.0.0"
}

terraform {
  required_version = "0.11.1"
}
