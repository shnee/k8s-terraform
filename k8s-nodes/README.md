
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
