terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
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

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.images"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.images.name
}

# Create the machine
resource "libvirt_domain" "master-domain" {
  name   = "k8s-tf-master"
  memory = var.node-memory
  vcpu   = var.node-vcpus

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
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

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
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
