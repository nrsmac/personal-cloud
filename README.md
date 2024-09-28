# Personal Cloud
This repo is home to configuration and IaC to provision and configure my personal 'cloud' services hosted on bare-metal with Proxmox. I am transitioing to using OpenTofu instead of manual configuration to provide more flexibility and reproducible builds. My aim is to keep everything configurable and up-to-date, so you can deploy it on your own home server or on public cloud environments.

Tools used:
- [Proxmox](https://www.proxmox.com/) -- Virtual Environment/"OS"
- [OpenTofu](https://https://opentofu.org) -- open-source Terraform alternative for IaC
- [K3s](https://k3s.io) Kubernetes  (Work-in-Progress)
- [Tailscale](https://tailscale.com) for networking
  - Investigating [headscale](https://headscale.net) as a FOSS alternative

## Quick start
- Clone the repo: 
  ```bash
  git clone https://github.com/nrsmac/personal-cloud.git
  ```
- Populate variables in `./terraform/tfvars` (see[ Configuring OpenTofu Variables](#configuring-opentofu-variables)):
- Provision VMs (eventually deploy K3s)
    ```bash
    tofu init
    tofu apply
    ```

## Instructions
**Prerequisites**:
- A Proxmox installation (either in a VM or on baremetal) with:
    - An LVM storage on your Proxmox cluster.
    - **HTTPS with non self-signed certificates** are required for terraform, and I've had mixed results with the default self-signed certificates. I used Tailscale to simplify this process.
    - A cloud-init image of your choice configured as a template.
         I followed [Techno Tim's tutorial for creating a cloud-init template](https://technotim.live/posts/cloud-init-cloud-image/)
    - An SSH keypair generated for Proxmox
- OpenTofu installed on your local machine.

### Configuring OpenTofu Variables
Create a new file in the cloned repo ./terraform/terraform.tfvars and copy-paste the following values:
```
PM_API_URL="https://<your-proxmox-fqdn-or-IP>:8006/api2/json"
PM_API_TOKEN_ID=""
PM_API_TOKEN_SECRET=""  
SSH_PUBLIC_KEY= <<EOF
# Public SSH key goes here
EOF
CLONE_TEMPLATE_NAME="ubuntu-cloud"
RESOURCE_POOL_NAME="closed"
STORAGE_NAME="local-lvm"
```

If you don't know/have any of these values, please read the next section

### Configuring Proxmox
In order for OpenTofu to provision resources on Proxmox, your cluster needs:
- A role for the Terraform Provider (terraform-prov) 
- A user "terraform-prov@pve" with the terraform-prov role
- An API token ID and key to authenticate with Proxmox from OpenTofu 

I took these instructions from Telmate's Proxmox Terraform Provider guide: [Creating the Proxmox user and role for terraform](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/index.md#creating-the-proxmox-user-and-role-for-terraform)

#### Creating the Terraform user and role
You can use the Proxmox GUI, but I used the shell (found by right-clicking on your node in the sidebar):
![Accessing the shell from the Proxmox GUI by right-clicking on the cluster name and selecting "Shell" from the dropdown](https://github.com/nrsmac/personal-cloud/blob/main/assets/proxmox-shell.png?raw=true)

```bash
# Create the role
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

#Create user
pveum user add terraform-prov@pve --password <password>

# Assume role 
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```
#### Create the API keys
Go to the API Keys page in the Proxmox interface:
![Viewing the API Key list from Proxmox web interface](https://github.com/nrsmac/personal-cloud/blob/main/assets/proxmox-api-tokens.png?raw=true)

Create a new key for the terraform-prov@pve user:
  - User: terraform-prov@pve (the user we created in the previous ste)
  - Token ID: terraform-pro (or choose whatever works)
  - **Uncheck Priviege Separation** -- this has unfortunately been known to cause issues with the current Proxmox terraform provider
![Viewing the API Key list from Proxmox web interface](https://github.com/nrsmac/personal-cloud/blob/main/assets/proxmox-api-token.png?raw=true)
Copy the ID and secret key to `./terraform/terraform.tfvars`

### Using Ansible to bootstrap K3s
```bash
git clone https://github.com/k3s-io/k3s-ansible.git
```

You may need to install ansible.posix:
```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

