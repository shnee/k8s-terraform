#!/bin/bash

# This script will create environment variables for all of the output IPs. An
# anisble inventory file is created as well.
#
# Use eval $(./get-vm-ips.sh) to set env vars for ips.

terraform refresh > /dev/null

# The file to write the inventory to. This file will be completely overridden.
INVENTORY_FILE="inventory"

# Grab the the vm name prefix. We do this by greping all *.tfvars files making
# sure to cat terraform.tfvars last. Then we just grab the last grep result,
# this way we make sure any value in terraform.tfvars will take priority.
VM_NAME_PREFIX_VAR="vm-name-prefix"
VM_NAME_PREFIXES="$( \
    find . -name "*.tfvars" -exec grep "$VM_NAME_PREFIX_VAR" {} \; && \
    grep "$VM_NAME_PREFIX_VAR" terraform.tfvars)"
VM_NAME_PREFIX="$(
    echo "$VM_NAME_PREFIXES" | \
        tail -n 1 | \
        sed 's/^.*=\s*"\(.*\)"/\1/g')"

PUBLIC_IP_OUTPUT="groups_hostnames_ips"
PRIVATE_IP_OUTPUT="groups_hostnames_private_ips"
IP_TYPE="$PRIVATE_IP_OUTPUT"

# This command stores the output data in the format below.
# [
#   {
#     "group": "master",
#     "vms": [
#       {
#         "hostname": "ansible-test-master-0",
#         "ip": "52.14.114.48"
#       }
#     ]
#   },
#   {
#     "group": "worker",
#     "vms": [
#       {
#         "hostname": "ansible-test-worker-0",
#         "ip": "3.145.121.159"
#       },
#       {
#         "hostname": "ansible-test-worker-1",
#         "ip": "18.217.112.176"
#       }
#     ]
#   }
# ]
DATA="$(terraform show -json | \
    jq '.values.outputs.'"$IP_TYPE"'.value | to_entries |
        map({group: .key, vms:.value | to_entries |
        map({hostname:.key,ip:.value})})')"

# Pull out the groups from $DATA. The format is a single string with the groups
# separated by spaces, ie. "group1 group2 group3".
ANS_GROUPS="$(
    echo $DATA | \
        jq '.[] | .group' | \
        sed 's/"//g' | \
        tr '\n' ' '
    )"

# Clear the inventory file.
cat /dev/null > $INVENTORY_FILE

# For each group, write the VM info to $INVENTORY_FILE and also print a variable
# expression to stdout.
for GROUP in $ANS_GROUPS; do

    # Write the inventory file to $INVENTORY_FILE.
    echo "[$GROUP]" >> $INVENTORY_FILE
    echo $DATA | \
        jq '.[] | select(.group=="'"$GROUP"'") | .vms[] | 
            "\(.hostname) ansible_host=\(.ip)"' | \
        sed 's/"//g' \
            >> $INVENTORY_FILE

    # For this group, collect expressions into VARS. The format is:
    # HOSTNAME1=0.0.0.0
    # HOSTNAME2=0.0.0.0
    VARS="$(
        echo $DATA | \
            jq '.[] | select(.group=="'"$GROUP"'") | .vms[] | 
                "\(.hostname)=\(.ip)"' | \
            sed 's/"//g' | \
            sed "s/$VM_NAME_PREFIX-//g" | \
            sed 's/-/_/g'
        )"
    # Print the contents of $VARS converted to uppercase.
    echo "${VARS^^}"
done
