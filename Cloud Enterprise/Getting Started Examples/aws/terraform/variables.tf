variable "region" {
  default = "ap-northeast-1"
}

variable "zones" {
  type    = "list"
  default = ["b", "c"]
}

variable "profile" {
  description = "Your AWS profile name"
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

variable "instance_type" {
  default = "t2.xlarge"
}

variable "user_data" {
  default = "user_data.sh"
}

variable "remote_user" {
  default = "ubuntu"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}
