provider "oci" {
  region       = "ap-seoul-1"
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
}

locals {
  cidr_block                = "10.0.0.0/16"
  private_subnet_cidr_block = "10.0.0.0/24"
  public_subnet_cidr_block  = "10.0.1.0/24"
  main_ip                   = "10.0.0.10"
  vpn_ip                    = "10.0.1.10"
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key" {}
variable "compartment_id" {}
variable "ssh_public_key" {}
variable "main_boot_volume_ocid" {}
variable "vpn_boot_volume_ocid" {}
