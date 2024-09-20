#!/bin/bash
# import the magic file shout out to @paxtonhare ✨
# make sure you have pv installed for the pe and pei functions to work!
. demo-magic.sh
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
clear

cd ../../src/infra/terraform/ai-tour-aks-demo

TYPE_SPEED=40

p "# Check the pets namespace"
pei "kubectl get all -n pets"

p "# Deploy the demo application"
TYPE_SPEED=100
pei "argocd app create pets --sync-policy auto --repo \$(gh repo view --json url | jq .url -r) --revision HEAD --path src/manifests/kustomize/overlays/dev --dest-namespace pets --dest-server https://kubernetes.default.svc"
TYPE_SPEED=40

p "# Check the app sync status"
pei "argocd app list"

p "# Get the ArgoCD server password"
pei "argocd admin initial-password"

p "# Port-forward to the ArgoCD dashboard"
pei "kubectl port-forward svc/argocd-server -n argocd 8080:443"
pei "clear"

p "# Get the public IP of the ingress gateway"
pei "INGRESS_PUBLIC_IP=\$(kubectl get svc -n aks-istio-ingress aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

p "# Test the app using curl"
pei "curl -IL \"http://\${INGRESS_PUBLIC_IP}\" -H \"Host: admin.aks.rocks\""

p "# Test the app in the browser"
pei "echo \"\${INGRESS_PUBLIC_IP} admin.aks.rocks store.aks.rocks\" | sudo tee -a /etc/hosts"
pei "echo http://admin.aks.rocks"

p "# Add AI to the application"
pei "git fetch upstream feat/ai-rollout"
pei "git merge upstream/feat/ai-rollout"

p "# Check the changes"
pei "less src/manifests/kustomize/base/ai-service.yaml"

p "# Push the changes to remote"
pei "git push"

p "# Force app sync"
pei "argocd app sync pets --force"

p "# Watch the rollout"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the httproute weight distribution"
pei "kubectl describe httproute ai-service -n pets | grep -B 3 Weight:"

p "# Test the ai feature in the browser"
pei "echo http://admin.aks.rocks"

p "# Deploy a new version of the AI service"
pei "kubectl argo rollouts set image ai-service -n pets ai-service=ghcr.io/pauldotyu/aks-store-demo/ai-service:latest"

p "# Watch the rollout of the new version"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the httproute"
pei "kubectl describe httproute ai-service -n pets | grep -B 3 Weight:"

p "# Promote the new version of the AI service"
pei "kubectl argo rollouts promote ai-service -n pets"

p "# Check the httproute"
pei "kubectl describe httproute ai-service -n pets | grep -B 3 Weight:"

p "# Final promotion"
pei "kubectl argo rollouts promote ai-service -n pets"

p "# Watch the final rollout"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the final httproute"
pei "kubectl describe httproute ai-service -n pets | grep -B 3 Weight:"

p "# Test the new ai feature in the browser"
pei "echo http://admin.aks.rocks"

p "exit"
clear