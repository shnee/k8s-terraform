#!/bin/sh

# Use eval $(./get-vm-ips.sh) to set env vars for ips.

terraform refresh > /dev/null
IPS_JSON="$(terraform show -json | jq '.values.root_module.resources[] | select(.type == "libvirt_domain") | {name: .values.name, ip: .values.network_interface[0].addresses[0]}')"

echo $IPS_JSON | \
    jq 'select(.name | contains("master")) | .ip' | \
    xargs -I% echo export MASTER=%

echo $IPS_JSON | \
    jq 'select(.name | contains("worker")) | .ip' | \
    nl -v 0 | \
    awk '{print "export WORKER" $1 "=" $2}' | \
    sed 's/"//g'

