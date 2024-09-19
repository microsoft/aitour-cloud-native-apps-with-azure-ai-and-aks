#!/bin/bash

echo "Deleting ArgoCD app..."
argocd app delete pets --yes

echo "Resetting the forked demo repository..."
cd src/infra/terraform/ai-tour-aks-demo
git fetch upstream main
git reset --hard upstream/main
git push origin main --force

echo "Removing host entries..."
sudo sed -i '' '/admin.aks.rocks/d' /etc/hosts

echo "Reset complete!"