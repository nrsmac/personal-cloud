# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/cloud-init
variable "K3S_CLONE_TEMPLATE_NAME" {
    type=string
}
variable "K3S_RESOURCE_POOL_NAME" {
    type=string
}
variable "K3S_STORAGE_NAME" {
    type=string
}
variable "K3S_TARGET_NODE" {
    type=string
}
variable K3S_CI_USER {
    type=string
}
variable K3S_CI_PASSWORD {
    type=string
}
variable K3S_CI_SSH_PUBLIC_KEY_PATH {
    type=string
}
variable K3S_BASE_MASTER_IP {
    type=string
}
variable K3S_BASE_WORKER_IP {
    type=string
}
variable K3S_IP_GATEWAY {
    type=string
}
variable K3S_NETWORK_CIDR {
    type=number
}
variable K3S_WORKER_NODE_COUNT {
    type=number
}
data "local_file" "ssh_public_key" {
  filename = "${var.K3S_CI_SSH_PUBLIC_KEY_PATH}"
}

resource "proxmox_virtual_environment_vm" "k3s-master" {
  count = 1
  name = "k3s-master${count.index + 1}"
  node_name = var.K3S_TARGET_NODE

  initialization {

    ip_config {
      ipv4 {
        address = "${var.K3S_BASE_MASTER_IP}${count.index}/${var.K3S_NETWORK_CIDR}"
        gateway = var.K3S_IP_GATEWAY 
      }
    }

    user_account {
      username = var.K3S_CI_USER
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = var.K3S_STORAGE_NAME
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20 
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_vm" "k3s-worker" {
  count = var.K3S_WORKER_NODE_COUNT
  name = "k3s-worker${count.index + 1}"
  node_name = var.K3S_TARGET_NODE

  initialization {

    ip_config {
      ipv4 {
        address = "${var.K3S_BASE_WORKER_IP}${count.index}/${var.K3S_NETWORK_CIDR}"
        gateway = var.K3S_IP_GATEWAY 
      }
    }

    user_account {
      username = var.K3S_CI_USER
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = var.K3S_STORAGE_NAME
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local" 
  node_name    = var.K3S_TARGET_NODE 

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

# resource "proxmox_vm_qemu" "srv-k8s-nodes" {
#   count = var.K3S_WORKER_NODE_COUNT
#   name = "worker${count.index + 1}"
#   desc = "Kubernetes Worker ${count.index + 1}"
#   vmid = 101 + count.index
#   target_node = var.K3S_TARGET_NODE

#   clone = var.K3S_CLONE_TEMPLATE_NAME

#   agent = 1
#   cores = 2
#   sockets = 1
#   cpu = "host"
#   memory = 4096

#   bootdisk = "scsi0"
#   scsihw = "virtio-scsi-pci"
#   # cloudinit_cdrom_storage = "local-lvm"
#   onboot = true

#   os_type = "cloud-init"
#   ipconfig0 = "ip=${var.K3S_BASE_WORKER_IP}${count.index}/${var.K3S_NETWORK_CIDR},gw=${var.K3S_IP_GATEWAY}"
#   nameserver = "8.8.8.8 8.8.4.4 ${var.K3S_IP_GATEWAY}"
#   # searchdomain = "piinalpin.lab"
#   ciuser = var.K3S_CI_USER
#   cipassword = var.K3S_CI_PASSWORD
#   sshkeys = <<EOF
#   ${file(var.K3S_CI_SSH_PUBLIC_KEY_PATH)}
#   EOF

#   network {
#     bridge = "vmbr0"
#     model = "virtio"
#   }

#   disks {
#     scsi {
#       scsi0 {
#         disk {
#           size = 20
#           storage = var.K3S_STORAGE_NAME
#         }
#       }
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       network
#     ]
#   }
# }
