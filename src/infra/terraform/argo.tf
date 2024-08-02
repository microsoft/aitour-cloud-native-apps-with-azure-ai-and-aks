# resource "helm_release" "argocd" {
#   name             = "argocd-release"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   version          = "7.3.7"
#   namespace        = "argocd"
#   create_namespace = true
# }

# resource "helm_release" "argorollout" {
#   name             = "argorollouts-release"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-rollouts"
#   version          = "2.37.2"
#   namespace        = "argo-rollouts"
#   create_namespace = true
# }