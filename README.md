## Auto Create ArgoCD

Usage Example

```hcl
module "argocd" {
  source  = "registry.terraform.io/iits-consulting/bootstrap/argocd"
  version = "X.X.X"
  
  ### Common CRD collection Configuration, see https://github.com/iits-consulting/crds-chart
  custom_resource_definitions_enabled = true
  
  ### Registry Credentials Configuration for auto inject docker pull secrets, see https://github.com/iits-consulting/registry-creds-chart
  registry_credentials_enabled      = true
  registry_credentials_dockerconfig = var.dockerconfig_json_base64_encoded

  ### ArgoCD Configuration
  argocd_project_name              = "infrastructure-charts"
  argocd_git_access_token_username = "ARGOCD_GIT_ACCESS_TOKEN"
  argocd_git_access_token          = var.argocd_git_access_token
  argocd_project_source_repo_url   = "https://github.com/iits-consulting/showcase-otc-infrastructure-charts.git"
  argocd_project_source_path       = "stages/dev/infrastructure-charts"  
}
```
