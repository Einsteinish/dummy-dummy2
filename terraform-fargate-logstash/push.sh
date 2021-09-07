#!/bin/bash
# 
# Builds a Docker image and pushes to an ECR repository

# push.sh

set -e

source_path="$1"    # 1st argument from command line
repository_url="$2" # 2nd argument from command line
tag="${3:-latest}"  # checks if 3rd argument exists, if not, use "latest"

echo "source_path=$source_path"
echo "repository_url=$repository_url"
echo "tag=$tag"

# splits string using '.' and picks 4th item
region="$(echo "$repository_url" | cut -d. -f4)" 
echo "region=$region"

# splits string using '/' and picks 2nd item
image_name="$(echo "$repository_url" | cut -d/ -f2)" 
echo "image_name=$image_name"
echo
echo
echo "builds docker image..."
(cd "$source_path" && docker build -t "$image_name" .) 
echo
echo "login..."
aws ecr get-login-password --region $region| docker login -u AWS --password-stdin "https://$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$region.amazonaws.com"
echo
echo "tag image..."
docker tag "$image_name" "$repository_url":"$tag"
echo
echo "push image..."
docker push "$repository_url":"$tag" 
