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
  uri = "qemu+ssh://gert@gertie/system"
}

resource "libvirt_pool" "images" {
  name = "k8s-tf-images"
  type = "dir"
  path = var.disk-image-dir
}

# Add 'size' when we need more space. It must be used in conjuction with
# 'growpart' in cloud-init as well.
resource "libvirt_volume" "master-image" {
  name   = "k8s-tf-master"
  pool   = libvirt_pool.images.name
  source = var.ubuntu-image
  format = "qcow2"
}

resource "libvirt_volume" "worker-volumes" {
  name   = "k8s-tf-worker-${count.index}"
  pool   = libvirt_pool.images.name
  source = var.ubuntu-image
  format = "qcow2"
  count  = var.worker-nodes
}

data "template_file" "master-user-data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname = "k8s-tf-master"
  }
}

data "template_file" "worker-user-data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname = "k8s-tf-worker-${count.index}"
  }
  count = var.worker-nodes
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "master-init" {
  name           = "k8s-tf-master-init"
  user_data      = data.template_file.master-user-data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.images.name
}

resource "libvirt_cloudinit_disk" "worker-init" {
  name           = "k8s-tf-worker-${count.index}-init"
  user_data      = element(data.template_file.worker-user-data.*.rendered, count.index)
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.images.name
  count = var.worker-nodes
}

# Create the machine
resource "libvirt_domain" "master-domain" {
  name   = "k8s-tf-master"
  memory = var.node-memory
  vcpu   = var.node-vcpus

  cloudinit = libvirt_cloudinit_disk.master-init.id

  network_interface {
    network_name = "default"
    hostname     = "k8s-tf-master"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.master-image.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "worker-domains" {
  count = var.worker-nodes
  name   = "k8s-tf-worker-${count.index}"
  memory = var.node-memory
  vcpu   = var.node-vcpus

  cloudinit = element(libvirt_cloudinit_disk.worker-init.*.id, count.index)

  network_interface {
    network_name = "default"
    hostname     = "k8s-tf-worker-${count.index}"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.worker-volumes.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
