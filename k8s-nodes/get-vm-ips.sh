#!/bin/sh

# Use eval $(./get-vm-ips.sh) to set env vars for ips.

terraform refresh > /dev/null

IPS_JSON="$(terraform show -json | jq '.values.outputs')"

echo $IPS_JSON | \
    jq '."master-ips".value[]' | \
    nl -v 0 | \
    awk '{print "export MASTER" $1 "=" $2}' | \
    sed 's/"//g'

echo $IPS_JSON | \
    jq '."worker-ips".value[]' | \
    nl -v 0 | \
    awk '{print "export WORKER" $1 "=" $2}' | \
    sed 's/"//g'
