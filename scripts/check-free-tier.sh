#!/usr/bin/env bash
# check-free-tier.sh — End-of-session cost guardrail.
#
# Lists AWS resources in the current account/region that are likely to bill you.
# Run this before walking away from a session.
#
# Requires: aws CLI v2, the `bootcamp` profile (or AWS_PROFILE set).

set -euo pipefail

PROFILE="${AWS_PROFILE:-bootcamp}"
REGION="${AWS_REGION:-us-east-1}"

awsq() { aws --profile "$PROFILE" --region "$REGION" --output json "$@"; }

section() { printf '\n=== %s ===\n' "$1"; }

section "EC2 instances (running)"
awsq ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{Id:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`]|[0].Value,LaunchTime:LaunchTime}' \
  | jq -r '. // [] | (["InstanceId","Type","Name","LaunchTime"] | (., map(length*"-"))), (.[] | [.Id,.Type,.Name,.LaunchTime]) | @tsv' 2>/dev/null \
  | column -t -s $'\t' || true

section "EC2 instances (stopped — still costs EBS)"
awsq ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query 'Reservations[].Instances[].{Id:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`]|[0].Value}' \
  | jq -r '.'

section "Unattached EBS volumes (charged hourly)"
awsq ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[].{Id:VolumeId,Size:Size,Type:VolumeType,Created:CreateTime}' \
  | jq -r '.'

section "Elastic IPs (charged when not attached to a running instance)"
awsq ec2 describe-addresses \
  --query 'Addresses[].{Ip:PublicIp,Instance:InstanceId,Allocation:AllocationId}' \
  | jq -r '.'

section "NAT Gateways (should be EMPTY — ~\$32/mo each)"
awsq ec2 describe-nat-gateways \
  --filter "Name=state,Values=available,pending" \
  --query 'NatGateways[].{Id:NatGatewayId,Vpc:VpcId,State:State}' \
  | jq -r '.'

section "Load Balancers (should be EMPTY — ALB/NLB are not free-tier)"
awsq elbv2 describe-load-balancers \
  --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code}' 2>/dev/null \
  | jq -r '.' || echo "elbv2 call failed (no LBs or no permission — OK)"

section "RDS instances (should be EMPTY — we run Postgres in-cluster)"
awsq rds describe-db-instances \
  --query 'DBInstances[].{Id:DBInstanceIdentifier,Class:DBInstanceClass,Status:DBInstanceStatus}' 2>/dev/null \
  | jq -r '.' || echo "rds call failed (no RDS or no permission — OK)"

section "EKS clusters (should be EMPTY — k3s only)"
awsq eks list-clusters 2>/dev/null | jq -r '.' || echo "eks call failed — OK"

section "S3 buckets (informational)"
awsq s3api list-buckets --query 'Buckets[].Name' | jq -r '.[]'

section "Current month estimated charges (best-effort, requires Cost Explorer)"
awsq ce get-cost-and-usage \
  --time-period "Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d)" \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --query 'ResultsByTime[0].Total.UnblendedCost' 2>/dev/null \
  | jq -r '.' || echo "Cost Explorer not enabled / no permission. Enable it in Billing console (free)."

echo
echo "Done. Anything surprising? Investigate. Anything that bills? Tear it down."
