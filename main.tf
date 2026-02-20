
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "default1" {
  name = "default1"
  type = "dir"
  path = "/var/lib/virt/images"
}

resource "libvirt_volume" "fedora-qcow2" {
  name   = "fedora-qcow2"
  pool   = libvirt_pool.default1.name
  source = "/home/bhavyapratapsingh/Downloads/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = file("${path.module}/user-data")
  network_config = file("${path.module}/network-config")
  pool           = libvirt_pool.default1.name
}

resource "libvirt_domain" "fedora" {
  name   = "fedora001"
  memory = "2048"
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.fedora-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
