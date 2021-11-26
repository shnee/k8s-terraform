data "template_file" "user-datas" {
  template = file("${var.cloud-init-template}")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.hostname-prefix}-${count.index}"
  }
  count = var.num
}
