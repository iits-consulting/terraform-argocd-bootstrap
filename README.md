## Auto Create ArgoCD

Usage Example

```hcl
module "argocd" {
  source = "git::https://github.com/iits-consulting/terraform-argocd-bootstrap.git"
  
  ### CRD collection Configuration:
  custom_resource_definitions_enabled = true
  
  ### Registry Credentials Configuration:
  registry_credentials_enabled      = true
  registry_credentials_dockerconfig = var.dockerconfig_json_base64_encoded

  ### ArgoCD Configuration:
  argocd_enabled                   = true
  argocd_project_name              = "infrastructure-charts"
  argocd_git_access_token_username = "ARGOCD_GIT_ACCESS_TOKEN"
  argocd_git_access_token          = var.argocd_git_access_token
  argocd_project_source_repo_url   = "https://github.com/iits-consulting/showcase-otc-infrastructure-charts.git"
  argocd_project_source_path       = "stages/dev/infrastructure-charts"  
}
```