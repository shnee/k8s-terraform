terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

resource "libvirt_volume" "node-images" {
  name   = "${var.name-prefix}-base"
  pool   = var.pool-name
  source = var.base-image
  format = "qcow2"
}

resource "libvirt_volume" "node-images-resized" {
  name           = "${var.name-prefix}-${count.index}-resized"
  pool           = var.pool-name
  base_volume_id = libvirt_volume.node-images.id
  count          = var.num-nodes
  size           = var.node-disk-size
}

data "template_file" "network-config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "node-inits" {
  name           = "${var.name-prefix}-${count.index}-init"
  user_data      = element(var.user-datas.*.rendered, count.index)
  network_config = data.template_file.network-config.rendered
  pool           = var.pool-name
  count          = var.num-nodes
}

resource "libvirt_domain" "nodes" {
  count  = var.num-nodes
  name   = "${var.name-prefix}-${count.index}"
  memory = var.node-memory
  vcpu   = var.node-vcpus

  cloudinit = element(libvirt_cloudinit_disk.node-inits.*.id, count.index)

  network_interface {
    network_name   = var.network-name
    hostname       = "${var.name-prefix}-${count.index}"
    # wait_for_lease = true
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
    volume_id = element(libvirt_volume.node-images-resized.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

