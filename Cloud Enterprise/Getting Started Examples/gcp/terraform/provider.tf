provider "google" {
  region      = "${var.region}"
  project     = "${var.project}"
  credentials = "${file("~/.config/gcloud/${var.project}.json")}"
  version     = "1.3.0"
}

provider "template" {
  version = "1.0.0"
}

terraform {
  required_version = "0.11.1"
}
