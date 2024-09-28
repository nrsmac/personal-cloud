terraform {
  required_version = ">= 1.7.4"

  required_providers {
    proxmox = {
        source = "bpg/proxmox"
        version = "0.63.0"
    }
  }
}

variable "PM_API_URL" {
   type=string
}
variable "PM_ENDPOINT" {
   type=string
}
variable "PM_API_TOKEN_ID" {
   type=string
}
variable "PM_API_TOKEN_SECRET" {
   type=string
}
variable "PM_USER" {
   type=string
}
variable "PM_PASSWORD" {
   type=string
}


provider "proxmox" {
    endpoint = var.PM_ENDPOINT
    username = var.PM_USER
    password = var.PM_PASSWORD
    insecure=true
    # ssh {
    #     agent = true
    # }
}