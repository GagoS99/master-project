#!/usr/bin/env bash
# bootstrap-tf-backend.sh — One-shot creation of the S3 bucket + DynamoDB
# table that hold Terraform remote state. Run once, before `terraform init`
# with the S3 backend.
#
# Resources created:
#   - S3 bucket  $BUCKET   (versioning on, public access blocked)
#   - DynamoDB   $TABLE    (LockID PK, PAY_PER_REQUEST)

set -euo pipefail

PROFILE="${AWS_PROFILE:-bootcamp}"
REGION="${AWS_REGION:-us-east-1}"
BUCKET="${1:-}"
TABLE="${2:-bootcamp-tfstate-lock}"

if [[ -z "$BUCKET" ]]; then
  echo "Usage: $0 <bucket-name> [table-name]"
  echo "  Bucket names must be globally unique. Suggestion:"
  echo "    bootcamp-tfstate-\$(whoami)-\$(openssl rand -hex 3)"
  exit 2
fi

awsq() { aws --profile "$PROFILE" --region "$REGION" "$@"; }

echo "==> Creating S3 bucket: $BUCKET"
if [[ "$REGION" == "us-east-1" ]]; then
  awsq s3api create-bucket --bucket "$BUCKET"
else
  awsq s3api create-bucket --bucket "$BUCKET" \
    --create-bucket-configuration "LocationConstraint=$REGION"
fi

echo "==> Enabling versioning"
awsq s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

echo "==> Blocking public access"
awsq s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "==> Enabling default SSE-S3 encryption"
awsq s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "==> Creating DynamoDB lock table: $TABLE"
awsq dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

echo "==> Waiting for table to be ACTIVE"
awsq dynamodb wait table-exists --table-name "$TABLE"

cat <<EOF

Done. Add this to infra/terraform/backend.tf:

terraform {
  backend "s3" {
    bucket         = "$BUCKET"
    key            = "dev/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$TABLE"
    encrypt        = true
  }
}

Then: terraform init -migrate-state
EOF
