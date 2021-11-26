#!/bin/sh

aws ec2 describe-instance-status | \
    jq '.InstanceStatuses[] | {id: .InstanceId, instance_status: .InstanceStatus.Status, system_status: .SystemStatus.Status}'
