#######################################################
#### Variables to configure (or be prompted about) ####
#######################################################

# Your aws profile name
variable "profile" {
  description = "Your aws profile"
}

# Your IP address, so that you will be whitelisted against security groups
variable "trusted_network" {
  description = "CIDR formatted IP (<IP Address>/32) or network that will be allowed access (you can use 0.0.0.0/0 for unrestricted access)"
}

# General name tag that will be given to spun up instances
variable "name" {
  description = "An idenfitying name used for names of cloud resources"
}

#######################################################
######### Variables you may want to configure #########
#######################################################

# Region to set up ece in
variable "region" {
  default = "us-east-2"
}

# Desired AZs, must have 3.
variable "zones" {
  type    = "list"
  default = ["a","b","c"]
}

#######################################################
#### Editable ECE installation-specific variables #####
#######################################################

# ECE instances's VPC & Subnet cidr
variable "cidr" {
  default = "192.168.100.0/24"
}

# ECE instance type
variable "instance_type" {
  default = "t2.xlarge"
}

# Path to your public key, which will be used to log in to ece instances
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

# Path to your private key for ssh login to servers
variable "private_key" {
  default = "~/.ssh/id_rsa"
}

# An additional volume that will be used by ECE, and its OS represented name
variable "secondary_device_name" {
  default="xvdb"
}

# 
variable "secondary_device_size" {
  default=100
}

# root device size for the ece instances
variable "root_device_size" {
  default=50
}

# Ece version to be installed by ansible
# Must be supported by the ansible playbook
variable "ece-version" {
  default="2.4.0"
}

#######################################################
########## Un-editable Variables ######################
#######################################################

# User to log in to instances and perform install
# To change this you'll need to modify current way of fetching the aws AMI
variable "remote_user" {
  default = "ubuntu"
}