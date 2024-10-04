variable SSH_PUBLIC_KEY_PATH {
    type=string
}
variable STORAGE_NAME {
    type=string
}
variable TARGET_NODE {
    type=string
}
variable CI_USER {
    type=string
}
variable CI_PASSWORD {
    type=string
}
variable IP_GATEWAY {
    type=string
}
variable NETWORK_CIDR {
    type=number
}
variable MASTER_CPU_CORES {
    type=number
}
variable MASTER_RAM_MB {
    type=number
}
variable MASTER_STORAGE_GB {
    type=number
}
variable WORKER_NODE_COUNT {
    type=number
}
variable WORKER_RAM_MB {
    type=number
}
variable WORKER_CPU_CORES {
    type=number
}
variable BASE_MASTER_IP {
    type=string
}
variable BASE_WORKER_IP {
    type=string
}
data "local_file" "ssh_public_key" {
  filename = "${var.SSH_PUBLIC_KEY_PATH}"
}
resource "proxmox_virtual_environment_vm" "barracuda" {
  count = 1
  name = "barracuda-${count.index + 1}"
  node_name = var.TARGET_NODE

  initialization {

    ip_config {
      ipv4 {
        address = "${var.BASE_MASTER_IP}${count.index}/${var.NETWORK_CIDR}"
        gateway = var.IP_GATEWAY 
      }
    }

    user_account {
      username = var.CI_USER
      password = var.CI_PASSWORD
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  cpu {
    cores = var.MASTER_CPU_CORES 
  }

  memory {
    dedicated = var.MASTER_RAM_MB
  }

  disk {
    datastore_id = var.STORAGE_NAME
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.MASTER_STORAGE_GB
  }

  network_device {
    bridge = "vmbr0"
  }

  vga {
    type = "virtio-gl"
  }
}
resource "proxmox_virtual_environment_vm" "personal" {
  count = 1
  name = "personal"
  node_name = var.TARGET_NODE

  initialization {

    ip_config {
      ipv4 {
        address = "${var.BASE_MASTER_IP}8/${var.NETWORK_CIDR}"
        gateway = var.IP_GATEWAY 
      }
    }

    user_account {
      username = var.CI_USER
      password = var.CI_PASSWORD
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  cpu {
    cores = var.MASTER_CPU_CORES 
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.STORAGE_NAME
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 15  # GB
  }

  network_device {
    bridge = "vmbr0"
  }

  vga {
    type = "virtio-gl"
  }
}
resource "proxmox_virtual_environment_vm" "browsing" {
  count = 1
  name = "browsing"
  node_name = var.TARGET_NODE

  initialization {

    ip_config {
      ipv4 {
        address = "${var.BASE_MASTER_IP}9/${var.NETWORK_CIDR}"
        gateway = var.IP_GATEWAY 
      }
    }

    user_account {
      username = var.CI_USER
      password = var.CI_PASSWORD
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  cpu {
    cores = var.MASTER_CPU_CORES 
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.STORAGE_NAME
    file_id      = proxmox_virtual_environment_download_file.tails_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 15  # GB
  }

  network_device {
    bridge = "vmbr0"
  }

  vga {
    type = "virtio-gl"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local" 
  node_name    = var.TARGET_NODE 
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
resource "proxmox_virtual_environment_download_file" "tails_cloud_image" {
  content_type = "iso"
  datastore_id = "local" 
  node_name    = var.TARGET_NODE 
  url = "https://download.tails.net/tails/stable/tails-amd64-6.7/tails-amd64-6.7.iso"
}

