#!/bin/bash
aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId'