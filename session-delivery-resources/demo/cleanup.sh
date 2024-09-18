#!/bin/bash

export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "Destroying Terraform created resources..."
cd src/infra/terraform
terraform destroy -var="owner=$(whoami)" --auto-approve
rm terraform.tfstate*

echo "Resetting the forked demo repository..."
cd ./ai-tour-aks-demo
git fetch upstream main
git reset --hard upstream/main
git push origin main --force

echo "Deleting the forked demo repository..."
cd ..
rm -rf ai-tour-aks-demo
gh auth login -h github.com -s delete_repo
gh repo delete $(gh api user --jq .login)/ai-tour-aks-demo --yes

echo "All cleaned up"