vm-name-prefix = "ansible-test"

# A CIDR block ending in '/32' equates to a single IP address, '0.0.0.0/0'
# equates to any ip address.
admin-ips = [ "8.8.8.8/32", "0.0.0.0/0" ]

disk-image-dir = "/path/to/disk/pool/"
libvirt-connection-url = "qemu+ssh://<user>@<host>/system"

node-memory = 2048
node-vcpus = 2

################################################################################
# AWS EC2 instance types
################################################################################

# 1 GiB, 1 vcpu, only one that is free.
# This one won't work with k8s because it requires at least 2 vcpus.
aws-ec2-instance-type = "t2.micro"

# 4 GiB, 2 vcpus
# aws-ec2-instnce-type = "t2.medium"

################################################################################
# AWS images (AMIs)
################################################################################

## Amazon Linux 2
# AWS Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon - 2021.11.11 - free
# base-image = "ami-00be885d550dcee43"
# AWS Amazon Linux 2 AMI (HVM), SSD Volume Type - us-east-2 - 2021.11.12 - free
base-image = "ami-0dd0ccab7e2801812"

## CentOS
# CentOS 7.9.2009 x86_64 - us-east-2 - 2021-11-15
# base-image = "ami-00f8e2c955f7ffa9b"
# CentOS 8.4.2105 x86_64 - us-east-2 - 2021-11015
# base-image = "ami-057cacbfbbb471bb3"

## Ubuntu
# Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
# us-east-2 - (64-bit x86) - 2021.11.12 - free
# base-image = "ami-0629230e074c580f2"

## Arch linux
# arch-linux-lts-hvm-2021.06.02.x86_64-ebs - us-east-2
# base-image = "ami-02653f06de985e3ba"

################################################################################
# libvirt images
################################################################################

# base-image = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
# From https://cloud.centos.org/centos/7/images/ from	2020-11-12 06:52
# base-image = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2009.qcow2"

################################################################################
# Keys/Passwords
################################################################################

# Password hash created with:
# python3 -c 'import crypt; print(crypt.crypt("linux", crypt.mksalt(crypt.METHOD_SHA512)))'
# where "linux" is the password.
root-admin-passwd = "$6$fiLRWvGQkdK.MnZA$Co9NkA5ruuBUA389JzmKJiC8gKRohmyM09AFnVBOD7ErZnxK4RHMUlKvYg1HSgwaCXTl7H/q1svoeQeUfgc6f0"

root-admin-pub-key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfDcjMFmWd6qy9KIlnIHNbEfeNLHC885UUH3jGwESmMTpFfPUn01t9hq5GGaFDrBR55VgdKebAv2JSVl209+r3tE5XxUX5/s2Pu3o2283PiZhA+D18skL7fzaolygOY8mxi9CZSDFia//lLbqT/OE45VGahVBRtda4gmjrade0XRKqjJUCkIo6huG9Ub6yP4gFtFU/C1rRvQo0hqT/imsMYU0Q5XzrKVWv3CpzA7EIQq8llU0fRGMuXWYYOXznPeqqf5BTbWhMWUXVS0o7Cz+zvbxwq1dOR1qHbJ8Vrkt30Cz5QEd159dIM3LHCtOHnveeOpkFo0RqkhQdpZM+2cKzESvivGNGP9h+PrSjcveADxVwDHcxguumUyM012M3yR8cK9KY+GqW5jPdAs13yXGTG4OWiQKeKEgX910l/FndhQi0tSpSEhIlfcEpa3k3P8RrhKJbwiRgR7Qvus4R/KU+lx4OiOr4RKyPQJobC0i0/bvqkw+UHWp4U0Hqivjsb6k= admin"
