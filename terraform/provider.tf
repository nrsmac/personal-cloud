terraform {
  required_version = ">= 1.7.4"

  required_providers {
    proxmox = {
        source = "telmate/proxmox"
        version = "3.0.1-rc3"
    }
  }
}

variable "PM_API_URL" {
   type=string
}
variable "PM_API_TOKEN_ID" {
   type=string
}
variable "PM_API_TOKEN_SECRET" {
   type=string
}

provider "proxmox" {
  pm_api_url = var.PM_API_URL
  pm_api_token_id = var.PM_API_TOKEN_ID
  pm_api_token_secret = var.PM_API_TOKEN_SECRET

  pm_tls_insecure = true

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }

}