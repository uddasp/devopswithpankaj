#!/bin/bash
# bootstrap-backend.sh
# Run this once with AWS CLI + admin perms
set -euo pipefail

REGION="us-east-1"
PROJECT="devopswithpankaj"
BUCKET_NAME="${PROJECT}-tfstate"
TABLE_NAME="${PROJECT}-tfstate"

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region $REGION  #/
#  --create-bucket-configuration LocationConstraint=$REGION

aws s3api put-bucket-versioning \
 --bucket "$BUCKET_NAME" \
 --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Tag the bucket
aws s3api put-bucket-tagging \
  --bucket "$BUCKET_NAME" \
  --tagging "TagSet=[{Key=StateBucket,Value=${PROJECT}-tfstate}]"

echo "Creating DynamoDB table: $TABLE_NAME"
aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION \
  --tags \
    Key=StateTable,Value=${PROJECT}-table \

# Save to local backend config
cat > backend.tfstate << EOF
bucket         = "$BUCKET_NAME"
key            = "devopswithpankaj/terraform.tfstate"
region         = "$REGION"
dynamodb_table = "$TABLE_NAME"
encrypt        = true
EOF

echo "Bucket: $BUCKET_NAME"
echo "Table:  $TABLE_NAME"
