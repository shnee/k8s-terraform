#!/bin/bash

# This script will grab the IPs for libvirt VMs. This script is only needed when
# using a bridge as the network for the VMs. This should only be needed while
# https://github.com/dmacvicar/terraform-provider-libvirt/issues/891 is
# unresolved.

# These are the network interfaces that this script will attempt to get the IP
# address for.
# Ubuntu 20.04    ens3
# Centos 7 & 8    eth0
NET_INTERFACES="eth0 ens3"

LIBVIRT_CONNECTION_URL="libvirt-connection-url"
VM_NAME_PREFIX="vm-name-prefix"

INV_GROUPS="$( \
cat terraform.tfstate | \
    jq '.resources[] | select(.type=="libvirt_domain") | .module' | \
    sed 's/".*\[\\"\(.*\)\\.*$/\1/g' )"

# Grab the connection URL and the vm name prefix. We do this by greping all
# *.tfvars files making sure to cat terraform.tfvars last. Then we just grab the
# last grep result, this way we make sure any value in terraform.tfvars will
# take priority.
CONN_URLS="$( \
    find . -name "*.tfvars" -exec grep "$LIBVIRT_CONNECTION_URL" {} \; && \
    grep "$LIBVIRT_CONNECTION_URL" terraform.tfvars)"

CONN_URL="$(echo "$CONN_URLS" | tail -n 1 | sed 's/^.*=\s*"\(.*\)"/\1/g')"

NAME_PREFIXES="$( \
    find . -name "*.tfvars" -exec grep "$VM_NAME_PREFIX" {} \; && \
    grep "$VM_NAME_PREFIX" terraform.tfvars)"

NAME_PREFIX="$(echo "$NAME_PREFIXES" | tail -n 1 | sed 's/^.*=\s*"\(.*\)"/\1/g')"

# These can be used for debugging.
# echo "Using connection URL: $CONN_URL"
# echo "Using prefix: $NAME_PREFIX"

# Get the names of our VMs from libvirt.
VMS="$(virsh -c $CONN_URL list --all | grep $NAME_PREFIX | awk '{print $2}')"

# Convert the lines of VM names to an array.
OLD_IFS=$IFS
IFS=$'\n'
VMS=($VMS)
IFS=$OLD_IFS

# Loop over our VM array and grab the ipv4 IP address from libvirt. Then add the
# result to VM_IP_PAIRS as <vm-name>:<ipv4-address>.
VM_IP_PAIRS=""
for VM in "${VMS[@]}"; do
    for INTERFACE in $NET_INTERFACES; do
        IP="$( \
            virsh -c $CONN_URL qemu-agent-command $VM '{"execute": "guest-network-get-interfaces"}' | \
            jq '.return[] | select(.name=="'"$INTERFACE"'") | ."ip-addresses"[] | select(."ip-address-type"=="ipv4") | ."ip-address"' | \
            sed 's/"//g')"
        # Add the VM:IP pair if IP is not empty.
        if [ ! -z "$IP" ]; then
            VM_IP_PAIRS="$VM_IP_PAIRS"$'\n'"$VM:$IP"
        fi
    done
done

# Write inventory
cat /dev/null > inventory
for GROUP in $INV_GROUPS; do
    echo "[$GROUP]" >> inventory
    echo "$VM_IP_PAIRS" | \
        grep $GROUP | \
        sed 's/^\(.*\):\(.*\)$/\1 ansible_host=\2/g' >> inventory
done

# Print vars
echo "$VM_IP_PAIRS" | \
    sed 's/^\(.*\):\(.*\)$/\1=\2/g' | \
    sed s/$NAME_PREFIX-//g | \
    sed 's/-/_/g' | \
    awk '{print toupper($1)}'
