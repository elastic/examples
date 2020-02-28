variable "region" {
  default = "us-central1"
}

variable "zones" {
  type    = list(string)
  default = ["a", "b", "c"]
}

variable "trusted_network" {
  description = "CIDR formatted IP (<IP Address>/32) or network that will be allowed access (you can use 0.0.0.0/0 for unrestricted access)"
}

variable "name" {
  description = "An idenfitying name used for names of cloud resources"
}

variable "cidr" {
  default = "192.168.100.0/24"
}

variable "machine_type" {
  default = "n1-standard-16"
}

variable "gcp_key_filename" {
  description = "What's the json key filename located in your <home>/.gcloud/ directory path?"
}

variable "project" {
  description = "What is the name of the project you would like resources to be created under in GCP?"
}

variable "remote_user" {
  default = "elastic"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  default = "~/.ssh/id_rsa"
}

variable "ece_version" {
  default = "2.4.3"
}