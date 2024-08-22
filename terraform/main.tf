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
variable K3S_SSH_USER {
    type=string
}
variable K3S_SSH_PASSWORD {
    type=string
}


resource "proxmox_vm_qemu" "master" {
  name        = "master01"
  target_node = var.K3S_TARGET_NODE
  clone       = var.K3S_CLONE_TEMPLATE_NAME
  desc        = "Master Node"
  #onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 2048
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  #qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "" 
          size = 25
        }
      }
    }
  }


  connection {
    type     = "ssh"
    user     = var.K3S_SSH_USER 
    password = var.K3S_SSH_PASSWORD
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "../netplan/01-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.K3S_SSH_USER} | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname master01",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

resource "proxmox_vm_qemu" "worker01" {
  name        = "worker01"
  target_node = var.K3S_TARGET_NODE
  clone       = var.K3S_CLONE_TEMPLATE_NAME
  desc        = "Worker Node 1"
  #onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 2048
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  #qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.K3S_STORAGE_NAME
          # size cannot be less than the image template (25G)
          size = 25
        }
      }
    }
  }

  #pool = "offense"

  connection {
    type     = "ssh"
    user     = var.K3S_SSH_USER
    password = var.K3S_SSH_PASSWORD
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "../netplan/02-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.K3S_SSH_USER} | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname worker01",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }

}

resource "proxmox_vm_qemu" "worker02" {
  name        = "worker02"
  target_node = var.K3S_TARGET_NODE
  clone       = var.K3S_CLONE_TEMPLATE_NAME
  desc        = "Worker Node 2"
  #onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 2048
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  #qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.K3S_STORAGE_NAME
          # size cannot be less than the image template (25G)
          size = 25
        }
      }
    }
  }

  pool = var.K3S_RESOURCE_POOL_NAME

  connection {
    type     = "ssh"
    user     = var.K3S_SSH_USER
    password = var.K3S_SSH_PASSWORD
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "../netplan/03-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.K3S_SSH_USER} | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname worker02",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

# resource "proxmox_vm_qemu" "cloudinit-test" {
#     name = "terraform-test-vm"
#     desc = "A test for using terraform and cloudinit"

#     target_node = var.TARGET_NODE

#     pool = var.RESOURCE_POOL_NAME 

#     clone = var.CLONE_TEMPLATE_NAME

#     agent = 1

#     os_type = "cloud-init"
#     cores = 2
#     sockets = 1
#     vcpus = 0
#     cpu = "host"
#     memory = 2048
#     scsihw = "lsi"

#     # Setup the disk
#     disks {
#         ide {
#             ide3 {
#                 cloudinit {
#                     storage = var.STORAGE_NAME
#                 }
#             }
#         }
#         virtio {
#             virtio0 {
#                 disk {
#                     size            = 32
#                     cache           = "writeback"
#                     storage         = var.STORAGE_NAME
#                     iothread        = true
#                     discard         = true
#                 }
#             }
#         }
#     }

#     # Setup the network interface and assign a vlan tag: 256
#     network {
#         model = "virtio"
#         bridge = "vmbr0"
#         tag = 256
#     }

#     # Setup the ip address using cloud-init.
#     boot = "order=virtio0"
#     # Keep in mind to use the CIDR notation for the ip.
#     ipconfig0 = "ip=192.168.10.20/24,gw=192.168.10.1"

#     sshkeys = var.SSH_PUBLIC_KEY
# }