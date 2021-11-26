A Terraform script to create k8s nodes. This script has modules for creating the
nodes on a KVM/QEMU (libvirt) hypervisor or creating the nodes via AWS.

The modules allow you create N VMs of a specific type. So you could create 1
master node and 3 worker nodes or you could create 3 Ubuntu VMs and 5 CentOS
VMs, or whatever fits your needs.

Cloud-Init
----------------------------------------

Both the libvirt and aws modules use cloud-init for initial configuration of the
VMs.

Dependencies
----------------------------------------

TODO REM add libvirt provider
libvirt provider depends on mkisofs

security_driver = none for ubuntu host, link github issue.
https://github.com/dmacvicar/terraform-provider-libvirt/issues/546

Other
----------------------------------------

Create a password hash.
```shell
python3 -c 'import crypt; print(crypt.crypt("test", crypt.mksalt(crypt.METHOD_SHA512)))'
```
