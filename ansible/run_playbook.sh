#!/usr/bin/env bash

set -e

TF_DIR="../terraform"

ECR_REPO_URL=$(cd "$TF_DIR" && terraform output -raw ecr_repository_url)
S3_BUCKET=$(cd "$TF_DIR" && terraform output -raw s3_bucket_name)

ansible-playbook -i inventory.ini \
  -e "ecr_repo_url=$ECR_REPO_URL" \
  -e "s3_bucket=$S3_BUCKET" \
  playbook.yml
