# Demo Environment Setup and Walkthrough

This guide will walk you through a demo of progressively rolling out AI enabled applications on cloud native infrastructure. We will heavily use command line tools to deploy a demo e-commerce application to an AKS Automatic cluster using ArgoCD, and automate the process of safely deploying new iterations of the app with Argo Rollouts, Istio Service Mesh, and Gateway API.

## Pre-requisites

You will need the following tools installed on your machine.

> [!IMPORTANT]
> The commands listed below should be run in a POSIX compliant shell such as bash or zsh.

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)
- [GitHub CLI](https://cli.github.com/)
- [Terraform](https://www.terraform.io/downloads.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd)
- [Argo Rollouts Kubectl Plugin](https://argo-rollouts.readthedocs.io/en/stable/installation/#kubectl-plugin-installation)

## Getting started

Start by logging into GitHub CLI.

```bash
gh auth login -h github.com -s delete_repo
```

Clone this repository to your local machine.

```bash
gh repo clone microsoft/aitour-cloud-native-apps-with-azure-ai-and-aks
cd aitour-cloud-native-apps-with-azure-ai-and-aks
```

Login to the Azure CLI using the `az login` command.

```bash
az login --tenant <TENANT_ID>
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

Before running the `terraform apply` command, be sure you have the required preview features enabled in your subscription for provisioning an AKS Automatic cluster.

```bash
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.Dashboard
az provider register -n Microsoft.AlertsManagement
az feature register --namespace Microsoft.ContainerService --name EnableAPIServerVnetIntegrationPreview
az feature register --namespace Microsoft.ContainerService --name NRGLockdownPreview
az feature register --namespace Microsoft.ContainerService --name SafeguardsPreview
az feature register --namespace Microsoft.ContainerService --name NodeAutoProvisioningPreview
az feature register --namespace Microsoft.ContainerService --name DisableSSHPreview
az feature register --namespace Microsoft.ContainerService --name AutomaticSKUPreview
```


> [!WARNING]
> Wait until all the providers and features are registered before proceeding.

Once all preview features are registered, run the following command to propagate the feature registrations for the AKS Automatic cluster.

```bash
az provider register -n Microsoft.ContainerService
```

You should also have the following Azure CLI extensions installed.

```bash
az extension add --name aks-preview
az extension add --name amg
```

## Provision with Terraform

Assuming you are in the root of the cloned repository, navigate to the `src/infra/terraform` directory.

```bash
cd src/infra/terraform
```

The following commands will deploy the infrastructure with Terraform.

```bash
terraform init
terraform apply -var="owner=$(whoami)"
```

After the deployment is complete, export output variables which will be used in the next steps.

```bash
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
```

Download the kubeconfig file to connect to the AKS cluster.

```bash
az aks get-credentials --name $AKS_NAME --resource-group $RG_NAME
```

## Enable Azure Managed Prometheus metrics scraping

Configure Azure Managed Prometheus to scrape metrics from any Pod across all Namespaces that have Prometheus annotations. This will enable the Istio service mesh metrics scraping.

```bash
kubectl create configmap -n kube-system ama-metrics-prometheus-config --from-file prometheus-config
```

## Install GatewayAPI CRDs

Deploy GatewayAPI for the application.

> [!NOTE]
> The [Kubernetes Gateway API](https://github.com/kubernetes-sigs/gateway-api) project is still under active development and its CRDs are not installed by default in Kubernetes. You will need to install them manually. Keep an eye on the project's [releases](https://github.com/kubernetes-sigs/gateway-api/releases) page for the latest version of the CRDs.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

## Install Istio Gateways

After the GatewayAPI CRDs are installed, deploy internal and external Gateways that will utilize the AKS Istio Ingress Gateways that were provisioned by the Terraform deployment.

> [!NOTE]
> Additional information on this approach can be found in [this](https://azure.github.io/AKS/2024/08/06/istio-with-gateway-api) blog post.

```bash
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
```

## Install ArgoCD and Argo Rollouts

Add Argo's Helm repository

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

Install the ArgoCD Helm chart

```bash
helm upgrade argocd argo/argo-cd \
--install \
--namespace argocd \
--create-namespace \
--version 7.3.7 \
--set 'global.podAnnotations.karpenter\.sh/do-not-disrupt=true'
```

> [!TIP]
> AKS Automatic clusters leverages Karpenter (Node Autoprovision) for node autoscaling, so it can take a minute or two for the new node to be provisioned.

Install the Argo Rollouts Helm chart

```bash
helm upgrade argo-rollouts argo/argo-rollouts \
--install \
--namespace argo-rollouts \
--create-namespace \
--version 2.37.2 \
--set 'controller.podAnnotations.karpenter\.sh/do-not-disrupt=true' \
--set 'dashboard.podAnnotations.karpenter\.sh/do-not-disrupt=true'
```

This demo will use Argo Rollouts to manage the progressive delivery of the AI service. To do this, we will need to enable Argo Rollouts to use the Gateway API plugin.

To enable Argo Rollouts to use the Gateway API, you will need to install the TrafficRouter plugin. This can be done by creating a ConfigMap in the `argo-rollouts` namespace that points to the plugin binary. Latest versions of the plugin can be found [here](https://github.com/argoproj-labs/rollouts-plugin-trafficrouter-gatewayapi/releases).

Install the TrafficRouter plugin.

```bash
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
```

Restart the Argo Rollouts controller so that it can pick up the new plugin.

```bash
kubectl rollout restart deployment -n argo-rollouts argo-rollouts
```

Inspect the logs to ensure the plugin was loaded.

```bash
kubectl logs -n argo-rollouts -l app.kubernetes.io/name=argo-rollouts | grep gatewayAPI
```

Argo Rollouts will need to be able to edit HTTPRoute resources. Create a ClusterRole and ClusterRoleBinding for the Argo Rollouts service account.

```bash
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
```

## Demo app configuration

Using the output variables from the Terraform deployment, create a Namespace, ServiceAccounts, and ConfigMaps for the demo application.

Create a Namespace with a label for automatic Istio sidecar injection.

```bash
kubectl create namespace pets
kubectl label namespace pets istio.io/rev=asm-1-22
```

The ai-service, order-service, and makeline-service will use Azure Workload Identity for authentication. This is enabled using Azure User-Assigned Managed Identities with Federated Credentials which have been provisioned by the Terraform deployment. The last bit of configuration to enable Workload Identity on AKS are the ServiceAccounts and ConfigMaps for each of the services that need to interact with Azure services.

Create a ServiceAccount and ConfigMap for the **ai-service**.

```bash
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
```

Create a ServiceAccount and ConfigMap for the **makeline-service**.

```bash
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
```

Create a ServiceAccount and ConfigMap for the **order-service**.

```bash
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
```

## Demo repo setup

In order to demonstrate the progressive delivery of the AI service using ArgoCD and Argo Rollouts, you will need a fork of the demo repository. This way you can commit changes to your fork and deploy them using ArgoCD.

```bash
gh repo fork microsoft/aitour-cloud-native-apps-with-azure-ai-and-aks --fork-name ai-tour-aks-demo --clone
cd ai-tour-aks-demo
```

> [!CAUTION]
> Make sure to run the following command and select your forked repository as the default. Otherwise, you may run into issues with merging and pushing changes as you work through the demo.

```bash
gh repo set-default
```

> [!TIP]
> If you run into the following error message "failed to fork: HTTP 403: Name already exists on this account" when trying to fork the repository, it means you have already forked the repository. In this case, you should simply clone it again to your local machine, pull the latest, and force push to your forked repository to ensure you have the latest changes.

Here is an example of how to do this.

```bash
gh repo clone $(gh api user --jq .login)/ai-tour-aks-demo
cd ai-tour-aks-demo
gh repo set-default $(gh api user --jq .login)/ai-tour-aks-demo
git remote add upstream https://github.com/microsoft/aitour-cloud-native-apps-with-azure-ai-and-aks.git
git fetch upstream main
git reset --hard upstream/main
git push origin main --force
```

Update the current context to the ArgoCD namespace.

```bash
kubectl config set-context --current --namespace=argocd
```

Connect to the ArgoCD server.

```bash
argocd login --core
```

Run the following command to add your forked repository to ArgoCD.

> [!NOTE]
> This is required for ArgoCD to be able read from private repositories. In this case, we are using a public repository so this step is not necessary but it is good practice to add the repository to ArgoCD.

```bash
argocd repo add $(gh repo view --json url | jq .url -r) \
--username $(gh api user --jq .login) \
--password $(gh auth token)
```

> [!IMPORTANT]
> The demo environment is now set up and ready to demo to your audience. You can either walk through the rest of the steps below or run the `run-demo.sh` script in the `train-the-trainer/demo` directory. When running the demo script, you need to ensure you have `pv` installed on your machine. To install `pv`, run `brew install pv` on macOS or `sudo apt-get install pv` on Ubuntu.

## Demo app deployment with ArgoCD

Deploy the demo application.

> [!WARNING]
> Make sure you have not run the `gh repo set-default` command as mentioned above, you should do that now before running the next set of commands.

```bash
argocd app create pets \
--sync-policy auto \
--repo $(gh repo view --json url | jq .url -r) \
--revision HEAD \
--path src/manifests/kustomize/overlays/dev \
--dest-namespace pets \
--dest-server https://kubernetes.default.svc
```

Check the status of the application and wait for the **STATUS** to be **Synced** and **HEALTH** to be **Healthy**.

```bash
argocd app list
```

Optionally, you can use the ArgoCD Release Server UI to watch the application deployment.

Run the following command then click on the link below to open the ArgoCD UI.

```bash
# get the admin password
argocd admin initial-password

# port forward to the ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Browse to https://localhost:8080 and log in with the admin password (username is **admin**).

> [!NOTE]
> This can take a few minutes to deploy the application due to Node Autoprovisioning.

Once you see the application has deployed completely, press "Ctrl+C" to exit the dashboard, then run the following command to get the public IP address of the application and issue a curl command to test the application. You should see a **200 OK** response.

```bash
INGRESS_PUBLIC_IP=$(kubectl get svc -n aks-istio-ingress aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -IL "http://${INGRESS_PUBLIC_IP}" -H "Host: store.aks.rocks"
```

Add a hosts file entry on your local machine to browse to the application using a friendly URL.

```bash
echo "${INGRESS_PUBLIC_IP} admin.aks.rocks store.aks.rocks" | sudo tee -a /etc/hosts
```

Now you can browse to both the frontend and backend applications using the following URLs.

- [http://store.aks.rocks](http://store.aks.rocks)
- [http://admin.aks.rocks](http://admin.aks.rocks)

> [!NOTE]
> This is where you show the admin site and how AI is not enabled yet.

## Sprinkle in some AI magic ✨

Merge the **ai** branch to deploy the rollout for the **ai-service**.

```bash
git fetch upstream feat/ai-rollout
git merge upstream/feat/ai-rollout
```

Open the `src/manifests/kustomize/base/ai-service.yaml` manifest and note the canary steps in the manifest. The first step sets the weight to 50% for the canary service. The second step pauses the rollout. The third step sets the weight to 100% for the canary service. The fourth step pauses the rollout and waits for a final promotion.

```bash
less src/manifests/kustomize/base/ai-service.yaml
```

Press **q** to exit the **less** command.

Push the commit to the remote repository.

```bash
git push
```

Force an ArgoCD sync to deploy the ai-service rollout.

```bash
argocd app sync pets --force
```

When the app is fully synced, watch the rollout and wait for **Status** to show **✔ Healthy**.

```bash
kubectl argo rollouts get rollout ai-service -n pets -w
```

When the rollout is healthy, hit **CTRL+C** to exit the watch.

Run the following command to check on the AI service's HTTPRoute. You should see that it has been updated to 100/0 traffic split between the stable and canary with the stable service receiving all traffic.

```bash
kubectl describe httproute ai-service -n pets | grep -B 3 Weight:
```

Using a web browser, navigate to the store admin site and create a new product.

> [!NOTE]
> The AI service is now being used to generate the product descriptions ✨

Next, let's update the rollout to set the **ai-service** image to the **latest** version.

```bash
kubectl argo rollouts set image ai-service -n pets ai-service=ghcr.io/pauldotyu/aks-store-demo/ai-service:latest
```

Watch the rollout again this time in the argo rollouts dashboard and wait for **Status** to show **॥ Paused**.

```bash
kubectl argo rollouts dashboard
```

When the rollout is paused, hit **CTRL+C** to exit the watch then check the weights of the HTTPRoute. You should see that it has been updated to 50/50 traffic split between the stable and canary.

```bash
kubectl describe httproute ai-service -n pets | grep -B 3 Weight:
```

Promote the rollout from the Argo Rollouts dashboard to shift all traffic to the canary.

```bash
kubectl argo rollouts dashboard
```

Watch the rollout and wait for **Status** to show **॥ Paused**. When the rollout is paused, hit **CTRL+C** to exit the dashboard then check the weights of the HTTPRoute again.

You should see that it has been updated to 0/100 traffic split with the canary service receiving all traffic.

```bash
kubectl describe httproute ai-service -n pets | grep -B 3 Weight:
```

All that is left is to promote the canary to the stable version. We can do this using the Argo Rollouts CLI.

```bash
kubectl argo rollouts promote ai-service -n pets
```

Watch the rollout one last time to see the stable version is now running the latest version and after a few minutes the rollout will scale down the **revision:1** ReplicaSet pods.

```bash
kubectl argo rollouts get rollout ai-service -n pets -w
```

When you see the **Status** show **✔ Healthy** and **revision:1** ReplicaSet status as **ScaledDown**, hit **CTRL+C** to exit the watch.

Take a look at the HTTPRoute weights one last time to see that the stable service is now receiving all traffic.

```bash
kubectl describe httproute ai-service -n pets | grep -B 3 Weight:
```

Go back to the store admin site and edit the product you created earlier.

> [!NOTE]
> The AI service is now being used to generate the product images too ✨✨

## BONUS: Import Istio dashboard into Azure Managed Grafana

Import the Istio dashboard into the Azure Managed Grafana instance.

```bash
az grafana dashboard import \
  --name $AMG_NAME \
  --resource-group $RG_NAME \
  --folder 'Azure Managed Prometheus' \
  --definition 7630
```

Navigate to your Azure Managed Grafana in the Azure portal, click on the endpoint link, then log in. In the Grafana portal, click **Dashboards** in the left navigation, then click the **Azure Managed Prometheus** folder. You should see the Istio dashboard along with other Kubernetes dashboards. Click on a few and explore the metrics.

## Troubleshooting

Some common issues you may run into.

### Unable to browse to the site?

Take a look at the **PROGRAMMED** status of the Gateway.

```bash
kubectl get gtw -n aks-istio-ingress gateway-external
```

If the value for **PROGRAMMED** is not **True**, then take a look at the status conditions for the Gateway.

```bash
kubectl describe gtw -n aks-istio-ingress gateway-external
```

If you see something like the following, then check to see if the managed ingress gateway is properly deployed.

```text
Message:               Failed to assign to any requested addresses: hostname "aks-istio-ingressgateway-external.aks-istio-ingress.svc.cluster.local" not found
```

Run the command below. If you don't see the managed ingress gateway, then you may need to deploy it manually.

```bash
kubectl get svc -n aks-istio-ingress
```

Also check the logs for the Istio Ingress Gateway.

```bash
ISTIO_INGRESS_POD_1=$(kubectl get po -n aks-istio-ingress -l app=aks-istio-ingressgateway-external -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n aks-istio-ingress $ISTIO_INGRESS_POD_1

ISTIO_INGRESS_POD_2=$(kubectl get po -n aks-istio-ingress -l app=aks-istio-ingressgateway-external -o jsonpath='{.items[1].metadata.name}')
kubectl logs -n aks-istio-ingress $ISTIO_INGRESS_POD_2
```

### Unable to see your ConfigMap from Azure App Configuration?

Common things to check include.

1. Ensure RBAC is properly configured for the managed identity that the AKS extension created.
1. Ensure the federated credential is properly configured for the managed identity that the AKS extension created.
1. Ensure the Azure App Configuration provider for Kubernetes pod has Azure tenant environment variables set.
1. Ensure the ServiceAccount has the clientId annotation set.

Typically you will see an error in the logs of the Azure App Configuration provider for Kubernetes pod if there is an issue.

```bash
kubectl logs -n azappconfig-system -l app.kubernetes.io/name=appconfig-provider
```

## Cleanup

Reset your demo repo to the upstream main branch.

```bash
git fetch upstream main
git reset --hard upstream/main
git push origin main --force
```

Delete the demo repo from your local machine.

```bash
cd ..
rm -rf ai-tour-aks-demo
```

Delete your fork of the demo repository.

```bash
gh repo delete $(gh api user --jq .login)/ai-tour-aks-demo --yes
```

Run the following command to destroy the infrastructure.

```bash
terraform destroy -var="owner=$(whoami)"
rm terraform.tfstate*
```

Delete the hosts file line entry on your local machine.

```bash
sudo sed -i '' '/admin.aks.rocks/d' /etc/hosts
```

## Feedback

Please provide any feedback on this sample as a GitHub issue.
