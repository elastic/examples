provider "google" {
  region      = var.region
  project     = var.project
  credentials = file(format("~/.config/gcloud/%s",var.gcp_key_filename))
}