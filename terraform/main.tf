# FROM https://kravensecurity.com/creating-local-kubernetes-cluster/

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

resource "proxmox_vm_qemu" "master" {
  count = 1
  name = "master"
  desc = "Kubernetes Master Nodes"
  vmid = 100 + count.index
  target_node = var.K3S_TARGET_NODE

  clone = var.K3S_CLONE_TEMPLATE_NAME 

  agent = 1
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096

  bootdisk = "scsi0"
  scsihw = "virtio-scsi-pci"
  onboot = true

  os_type = "cloud-init"
  ipconfig0 = "ip=${var.K3S_BASE_MASTER_IP}${count.index}/${var.K3S_NETWORK_CIDR},gw=${var.K3S_IP_GATEWAY}"
  nameserver = "8.8.8.8 8.8.4.4 ${var.K3S_IP_GATEWAY}"
  # searchdomain = "piinalpin.lab"
  ciuser = var.K3S_CI_USER
  cipassword = var.K3S_CI_PASSWORD
  sshkeys = <<EOF
  ${file(var.K3S_CI_SSH_PUBLIC_KEY_PATH)}
  EOF

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size = 20
          storage = var.K3S_STORAGE_NAME
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}

resource "proxmox_vm_qemu" "srv-k8s-nodes" {
  count = var.K3S_WORKER_NODE_COUNT
  name = "worker${count.index + 1}"
  desc = "Kubernetes Worker ${count.index + 1}"
  vmid = 101 + count.index
  target_node = var.K3S_TARGET_NODE

  clone = var.K3S_CLONE_TEMPLATE_NAME

  agent = 1
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096

  bootdisk = "scsi0"
  scsihw = "virtio-scsi-pci"
  # cloudinit_cdrom_storage = "local-lvm"
  onboot = true

  os_type = "cloud-init"
  ipconfig0 = "ip=${var.K3S_BASE_WORKER_IP}${count.index}/${var.K3S_NETWORK_CIDR},gw=${var.K3S_IP_GATEWAY}"
  nameserver = "8.8.8.8 8.8.4.4 ${var.K3S_IP_GATEWAY}"
  # searchdomain = "piinalpin.lab"
  ciuser = var.K3S_CI_USER
  cipassword = var.K3S_CI_PASSWORD
  sshkeys = <<EOF
  ${file(var.K3S_CI_SSH_PUBLIC_KEY_PATH)}
  EOF

  network {
    bridge = "vmbr0"
    model = "virtio"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size = 20
          storage = var.K3S_STORAGE_NAME
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}
