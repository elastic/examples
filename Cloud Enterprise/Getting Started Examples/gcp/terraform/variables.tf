variable "region" {
  default = "asia-northeast1"
}

variable "zones" {
  type    = "list"
  default = ["a", "b"]
}

variable "project" {
  description = "Your google project ID"
}

variable "trusted_network" {
  description = "Network ranges (your IP) that will be allowed administrative access"
}

variable "name" {
  description = "An idenfitying name used for names of cloud resources"
}

variable "cidr" {
  default = "10.13.37.0/24"
}

variable "machine_type" {
  default = "n1-standard-16"
}

variable "user_data" {
  default = "user_data.sh"
}

variable "remote_user" {
  default = "elastic"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}
