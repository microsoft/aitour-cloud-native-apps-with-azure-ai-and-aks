#!/bin/bash
# import the magic file shout out to @paxtonhare ✨
# make sure you have pv installed for the pei function to work!
. demo-magic.sh
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
clear

TYPE_SPEED=40
p "# Fork and clone the repo"

pei "gh auth login"
TYPE_SPEED=100
pei "gh repo fork microsoft/aitour-cloud-native-apps-with-azure-ai-and-aks --fork-name cloud-native-apps-with-azure-ai-and-aks-demo --clone"
TYPE_SPEED=40
pei "cd cloud-native-apps-with-azure-ai-and-aks-demo"

p "# Set the default repo to be the newly forked repo"
pe "gh repo set-default"

p "# Login to Azure and register the required features"
pei "az login"

TYPE_SPEED=100
pei "az feature register --namespace Microsoft.ContainerService --name EnableAPIServerVnetIntegrationPreview"
pei "az feature register --namespace Microsoft.ContainerService --name NRGLockdownPreview"
pei "az feature register --namespace Microsoft.ContainerService --name SafeguardsPreview"
pei "az feature register --namespace Microsoft.ContainerService --name NodeAutoProvisioningPreview"
pei "az feature register --namespace Microsoft.ContainerService --name DisableSSHPreview"
pei "az feature register --namespace Microsoft.ContainerService --name AutomaticSKUPreview"
pei "az provider register --namespace Microsoft.ContainerService"
pe "clear"


TYPE_SPEED=40

p "# Install the required CLI extensions"
pei "az extension add --name aks-preview"
pei "az extension add --name amg"
pe "clear"


p "# Provision the required Azure resources with Terraform"
pei "cd src/infra/terraform"
pe "terraform init"
pe "terraform apply"

p "# Export the required environment variables"

TYPE_SPEED=100
p "export RG_NAME=\$(terraform output -raw rg_name) \n
export AKS_NAME=\$(terraform output -raw aks_name) \n
export OAI_GPT_ENDPOINT=\$(terraform output -raw oai_gpt_endpoint) \n
export OAI_GPT_DEPLOYMENT_NAME=\$(terraform output -raw oai_gpt_model_name) \n
export OAI_DALLE_ENDPOINT=\$(terraform output -raw oai_dalle_endpoint) \n
export OAI_DALLE_DEPLOYMENT_NAME=\$(terraform output -raw oai_dalle_model_name) \n
export OAI_DALLE_API_VERSION=\$(terraform output -raw oai_dalle_api_version) \n
export OAI_IDENTITY_CLIENT_ID=\$(terraform output -raw oai_identity_client_id) \n
export AMG_NAME=\$(terraform output -raw amg_name) \n
export DB_CONTAINER_NAME=\$(terraform output -raw db_container_name) \n
export DB_DATABASE_NAME=\$(terraform output -raw db_database_name) \n
export DB_ENDPOINT=\$(terraform output -raw db_endpoint) \n
export DB_IDENTITY_CLIENT_ID=\$(terraform output -raw db_identity_client_id) \n
export SB_HOSTNAME=\$(terraform output -raw sb_hostname) \n
export SB_QUEUE_NAME=\$(terraform output -raw sb_queue_name) \n
export SB_IDENTITY_CLIENT_ID=\$(terraform output -raw sb_identity_client_id)"
TYPE_SPEED=40
export RG_NAME=$(terraform output -raw rg_name)
export AKS_NAME=$(terraform output -raw aks_name)
export OAI_GPT_ENDPOINT=$(terraform output -raw oai_gpt_endpoint)
export OAI_GPT_DEPLOYMENT_NAME=$(terraform output -raw oai_gpt_model_name)
export OAI_DALLE_ENDPOINT=$(terraform output -raw oai_dalle_endpoint)
export OAI_DALLE_DEPLOYMENT_NAME=$(terraform output -raw oai_dalle_model_name)
export OAI_DALLE_API_VERSION=$(terraform output -raw oai_dalle_api_version)
export OAI_IDENTITY_CLIENT_ID=$(terraform output -raw oai_identity_client_id)
export AMG_NAME=$(terraform output -raw amg_name)
export DB_CONTAINER_NAME=$(terraform output -raw db_container_name)
export DB_DATABASE_NAME=$(terraform output -raw db_database_name)
export DB_ENDPOINT=$(terraform output -raw db_endpoint)
export DB_IDENTITY_CLIENT_ID=$(terraform output -raw db_identity_client_id)
export SB_HOSTNAME=$(terraform output -raw sb_hostname)
export SB_QUEUE_NAME=$(terraform output -raw sb_queue_name)
export SB_IDENTITY_CLIENT_ID=$(terraform output -raw sb_identity_client_id)
pe "clear"


p "# Get the kubeconfig for the AKS cluster"
p "az aks get-credentials --name \$AKS_NAME --resource-group \$RG_NAME"
az aks get-credentials --name $AKS_NAME --resource-group $RG_NAME
pe "clear"


p "# Configure Azure Managed Prometheus to scrape configs"
pei "kubectl create configmap -n kube-system ama-metrics-prometheus-config --from-file prometheus-config"

p "# Install Gateway API"
pei "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml"
pe "clear"


p "# Deploy Gateways"
TYPE_SPEED=100
# this is just to print the command to the screen
# this will be done for all multi-line commands below
p "kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-internal
  namespace: aks-istio-ingress
spec:
  gatewayClassName: istio
  addresses:
  - value: aks-istio-ingressgateway-internal.aks-istio-ingress.svc.cluster.local
    type: Hostname
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-external
  namespace: aks-istio-ingress
spec:
  gatewayClassName: istio
  addresses:
  - value: aks-istio-ingressgateway-external.aks-istio-ingress.svc.cluster.local
    type: Hostname
  listeners:
  - name: default
    hostname: "*.aks.rocks"
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
EOF"
TYPE_SPEED=40
# this does the actual work
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-internal
  namespace: aks-istio-ingress
spec:
  gatewayClassName: istio
  addresses:
  - value: aks-istio-ingressgateway-internal.aks-istio-ingress.svc.cluster.local
    type: Hostname
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-external
  namespace: aks-istio-ingress
spec:
  gatewayClassName: istio
  addresses:
  - value: aks-istio-ingressgateway-external.aks-istio-ingress.svc.cluster.local
    type: Hostname
  listeners:
  - name: default
    hostname: "*.aks.rocks"
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
EOF
pe "clear"


p "# Add Argo Helm repo"
pei "helm repo add argo https://argoproj.github.io/argo-helm"
pei "helm repo update"

p "# Install Argo CD"
TYPE_SPEED=80
pei "helm install argocd argo/argo-cd --namespace argocd --create-namespace --version 7.3.7"
TYPE_SPEED=40
pe "clear"


p "# Install Argo Rollouts"
TYPE_SPEED=80
pei "helm install argo-rollouts argo/argo-rollouts --namespace argo-rollouts --create-namespace --version 2.37.2"
TYPE_SPEED=40
pe "clear"


p "# Install the Gateway API plugin for Argo Rollouts"
TYPE_SPEED=100
p "kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argo-rollouts-config
  namespace: argo-rollouts
data:
  trafficRouterPlugins: |-
    - name: "argoproj-labs/gatewayAPI"
      location: "https://github.com/argoproj-labs/rollouts-plugin-trafficrouter-gatewayapi/releases/download/v0.3.0/gateway-api-plugin-linux-amd64"
EOF"
TYPE_SPEED=40
# do the actual work
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argo-rollouts-config
  namespace: argo-rollouts
data:
  trafficRouterPlugins: |-
    - name: "argoproj-labs/gatewayAPI"
      location: "https://github.com/argoproj-labs/rollouts-plugin-trafficrouter-gatewayapi/releases/download/v0.3.0/gateway-api-plugin-linux-amd64"
EOF
pe "clear"


p "# Restart the Argo Rollouts deployment"
pei "kubectl rollout restart deployment -n argo-rollouts argo-rollouts"

p "# Verify the Gateway API plugin is installed"
pei "kubectl logs -n argo-rollouts -l app.kubernetes.io/name=argo-rollouts | grep gatewayAPI"

p "# Grant the Argo Rollouts service account permissions to manage the gateway"
TYPE_SPEED=100
p "kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gateway-controller-role
  namespace: argo-rollouts
rules:
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gateway-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: gateway-controller-role
subjects:
  - namespace: argo-rollouts
    kind: ServiceAccount
    name: argorollouts-release-argo-rollouts
EOF"
TYPE_SPEED=40
# do the actual work
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gateway-controller-role
  namespace: argo-rollouts
rules:
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gateway-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: gateway-controller-role
subjects:
  - namespace: argo-rollouts
    kind: ServiceAccount
    name: argorollouts-release-argo-rollouts
EOF
pe "clear"


p "# Create a new namespace for the application"
pei "kubectl create namespace pets"
p "# Label the namespace for automaticIstio sidecar injection"
pei "kubectl label namespace pets istio.io/rev=asm-1-22"
pe "clear"


p "# Create ServiceAccount and ConfigMap for ai-service"
TYPE_SPEED=100
p "kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: \$OAI_IDENTITY_CLIENT_ID
  name: ai-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ai-service-configs
  namespace: pets
data:
  USE_AZURE_OPENAI: "True"  
  USE_AZURE_AD: "True"
  AZURE_OPENAI_ENDPOINT: \$OAI_GPT_ENDPOINT
  AZURE_OPENAI_DEPLOYMENT_NAME: \$OAI_GPT_DEPLOYMENT_NAME
  AZURE_OPENAI_DALLE_ENDPOINT: \$OAI_DALLE_ENDPOINT
  AZURE_OPENAI_DALLE_DEPLOYMENT_NAME: \$OAI_DALLE_DEPLOYMENT_NAME
  AZURE_OPENAI_API_VERSION: \$OAI_DALLE_API_VERSION
EOF"
TYPE_SPEED=40
# do the actual work
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $OAI_IDENTITY_CLIENT_ID
  name: ai-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ai-service-configs
  namespace: pets
data:
  USE_AZURE_OPENAI: "True"  
  USE_AZURE_AD: "True"
  AZURE_OPENAI_ENDPOINT: $OAI_GPT_ENDPOINT
  AZURE_OPENAI_DEPLOYMENT_NAME: $OAI_GPT_DEPLOYMENT_NAME
  AZURE_OPENAI_DALLE_ENDPOINT: $OAI_DALLE_ENDPOINT
  AZURE_OPENAI_DALLE_DEPLOYMENT_NAME: $OAI_DALLE_DEPLOYMENT_NAME
  AZURE_OPENAI_API_VERSION: $OAI_DALLE_API_VERSION
EOF
pe "clear"


p "# Create ServiceAccount and ConfigMap for makeline-service"
TYPE_SPEED=100
p "kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: \$DB_IDENTITY_CLIENT_ID
  name: makeline-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: makeline-service-configs
  namespace: pets
data:  
  USE_WORKLOAD_IDENTITY_AUTH: "true"
  ORDER_QUEUE_HOSTNAME: \$SB_HOSTNAME
  ORDER_QUEUE_NAME: \$SB_QUEUE_NAME
  ORDER_DB_URI: \$DB_ENDPOINT
  ORDER_DB_NAME: \$DB_DATABASE_NAME
  ORDER_DB_API: "cosmosdbsql"
  ORDER_DB_CONTAINER_NAME: \$DB_CONTAINER_NAME
  ORDER_DB_PARTITION_KEY: "storeId"
  ORDER_DB_PARTITION_VALUE: "pets"
EOF"
TYPE_SPEED=40
# do the actual work
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $DB_IDENTITY_CLIENT_ID
  name: makeline-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: makeline-service-configs
  namespace: pets
data:  
  USE_WORKLOAD_IDENTITY_AUTH: "true"
  ORDER_QUEUE_HOSTNAME: $SB_HOSTNAME
  ORDER_QUEUE_NAME: $SB_QUEUE_NAME
  ORDER_DB_URI: $DB_ENDPOINT
  ORDER_DB_NAME: $DB_DATABASE_NAME
  ORDER_DB_API: "cosmosdbsql"
  ORDER_DB_CONTAINER_NAME: $DB_CONTAINER_NAME
  ORDER_DB_PARTITION_KEY: "storeId"
  ORDER_DB_PARTITION_VALUE: "pets"
EOF
pe "clear"


p "# Create ServiceAccount and ConfigMap for order-service"
TYPE_SPEED=100
p "kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: \$SB_IDENTITY_CLIENT_ID
  name: order-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: order-service-configs
  namespace: pets
data:
  USE_WORKLOAD_IDENTITY_AUTH: "true"
  ORDER_QUEUE_HOSTNAME: \$SB_HOSTNAME
  ORDER_QUEUE_NAME: \$SB_QUEUE_NAME
  FASTIFY_ADDRESS: "0.0.0.0"
EOF"
TYPE_SPEED=40
# do the actual work
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $SB_IDENTITY_CLIENT_ID
  name: order-service-account
  namespace: pets
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: order-service-configs
  namespace: pets
data:
  USE_WORKLOAD_IDENTITY_AUTH: "true"
  ORDER_QUEUE_HOSTNAME: $SB_HOSTNAME
  ORDER_QUEUE_NAME: $SB_QUEUE_NAME
  FASTIFY_ADDRESS: "0.0.0.0"
EOF
pe "clear"

p "# Set the default namespace to argocd"
pei "kubectl config set-context --current --namespace=argocd"

p "# Login to the ArgoCD release server"
pei "argocd login --core"

p "# Add repo credentials"
TYPE_SPEED=100
p "argocd repo add \$(gh repo view --json url | jq .url -r) --username \$(gh api user --jq .login) --password \$(gh auth token)"
argocd repo add $(gh repo view --json url | jq .url -r) --username $(gh api user --jq .login) --password $(gh auth token)
TYPE_SPEED=40

p "# Deploy the demo application"
TYPE_SPEED=100
p "argocd app create pets --sync-policy auto --repo \$(gh repo view --json url | jq .url -r) --revision HEAD --path src/manifests/kustomize/overlays/dev --dest-namespace pets --dest-server https://kubernetes.default.svc"
argocd app create pets --sync-policy auto --repo $(gh repo view --json url | jq .url -r) --revision HEAD --path src/manifests/kustomize/overlays/dev --dest-namespace pets --dest-server https://kubernetes.default.svc
TYPE_SPEED=40

p "# Check the app sync status"
pe "argocd app list"

p "# Check the ArgoCD dashboard"
pe "argocd admin dashboard"
pe "clear"


p "# Test the application"
pei "kubectl get svc -n aks-istio-ingress aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
pe "clear"

p "# Add AI to the application"
pei "git fetch upstream feat/ai-rollout"
pei "git merge upstream/feat/ai-rollout"
pe "less ../../../src/manifests/kustomize/base/ai-service.yaml "

p "# Push the changes to remote"
pei "git push"

p "# Force app sync"
pei "argocd app sync pets --force"

p "# Watch the rollout"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the httproute"
pei "kubectl describe httproute ai-service -n pets"

p "# Deploy a new version of the AI service"
pei "kubectl argo rollouts set image ai-service -n pets ai-service=ghcr.io/pauldotyu/aks-store-demo/ai-service:latest"

p "# Watch the rollout steps 1 and 2"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the httproute"
pei "kubectl describe httproute ai-service -n pets"

p "# Promote the new version of the AI service"
pei "kubectl argo rollouts promote ai-service -n pets"

p "# Watch the rollout steps 3 and 4"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# Check the httproute"
pei "kubectl describe httproute ai-service -n pets"

p "# Final promotion"
pei "kubectl argo rollouts promote ai-service -n pets"
pei "kubectl argo rollouts get rollout ai-service -n pets -w"

p "# BONUS: Import Istio dashboard to Azure Managed Grafana"
TYPE_SPEED=100
p "az grafana dashboard import \
  --name \$AMG_NAME \
  --resource-group \$RG_NAME \
  --folder 'Azure Managed Prometheus' \
  --definition 7630"
TYPE_SPEED=40
# do the actual work
az grafana dashboard import \
  --name $AMG_NAME \
  --resource-group $RG_NAME \
  --folder 'Azure Managed Prometheus' \
  --definition 7630