#!/bin/sh

# This script will create environment variables for all of the output IPs. It
# will also create a `ANSIBLE_INV` variable that will be a comma separated
# string of all the IPs. A anisble inventory file called "inventory is created
# as well.
#
# Use eval $(./get-vm-ips.sh) to set env vars for ips.

terraform refresh > /dev/null

# All terraform outputs in json format.
OUTPUTS_JSON="$(
    terraform show -json | \
        jq '.values.outputs' | \
        sed 's/-/_/g')"
# Just the IP address outputs in json format. Also all '-' characters are
# replaced by '_' becuase '-' causes jq some problems.
IPS_JSON="$(
    echo $OUTPUTS_JSON | \
        jq 'to_entries | .[] | select(.key | contains("ips"))')"
# An array of all node "types"
NODE_TYPE_ARRAY="$(
    echo $IPS_JSON | \
        jq '.value.value | to_entries | .[] | .key' | \
        sed 's/"//g' | \
        sed -z 's/\n/ /g;s/ $/\n/g')"

# Loop over all the node types and create an export line for each IP.
VM_IP_EXPORTS="$(
    for TYPE in $NODE_TYPE_ARRAY; do

        # Convert type, converts "master-ips" to "MASTER"
        TYPE_UPPER="$(echo ${TYPE^^} | sed s/_.*$//g)"
        echo "$IPS_JSON" | \
            jq '.value.value.'"$TYPE"'[]' | \
            # Add line numbers starting with 0.
            nl -v 0 | \
            # Print an export string with a type placeholder "__TYPE__".
            awk '{print "export __TYPE___" $1 "=" $2}' | \
            sed s/__TYPE__/$TYPE_UPPER/g
    done)"

ANSIBLE_INV="$(
    echo "$VM_IP_EXPORTS" | \
        sed 's/"//g' | \
        sed 's/^.*=//g' | \
        sed -z 's/\n/,/g;s/,$/\n/g')"

# Create an inventory file for ansible.
echo "# Wrote an Ansible inventory file at ./inventory"
echo "[k8s_nodes]" > inventory
echo $VM_IP_EXPORTS | \
    sed 's/"//g' | \
    sed 's/export //g' | \
    sed 's/ /\n/g' | \
    sed 's/^\(.*\)\(=.*\)$/\1 ansible_host\2/g' \
        >> inventory

echo $VM_IP_EXPORTS | sed 's/" /"\n/g'
echo export ANSIBLE_INV=$ANSIBLE_INV
