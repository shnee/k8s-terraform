terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt-connection-url
}

module "master-nodes" {
  source = "./modules/node"
  pool-name = libvirt_pool.images.name
  name-prefix = "${var.vm-name-prefix}-master"
  num-nodes = var.master-nodes
  base-image = var.ubuntu-image
  root-admin-passwd = var.root-admin-passwd
  root-admin-pub-key = var.root-admin-pub-key
  libvirt-connection-url = var.libvirt-connection-url
}

module "worker-nodes" {
  source = "./modules/node"
  pool-name = libvirt_pool.images.name
  name-prefix = "${var.vm-name-prefix}-worker"
  num-nodes = var.worker-nodes
  base-image = var.ubuntu-image
  root-admin-passwd = var.root-admin-passwd
  root-admin-pub-key = var.root-admin-pub-key
  libvirt-connection-url = var.libvirt-connection-url
}

resource "libvirt_pool" "images" {
  name = var.disk-image-pool-name
  type = "dir"
  path = var.disk-image-dir
}
