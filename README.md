## Auto Create ArgoCD

Usage Example

```hcl
module "argocd" {
  source  = "registry.terraform.io/iits-consulting/bootstrap/argocd"
  version = "X.X.X"
 
  ### ArgoCD Configuration
  argocd_project_name              = "infrastructure-charts"
  argocd_git_access_token_username = "ARGOCD_GIT_ACCESS_TOKEN"
  argocd_git_access_token          = var.argocd_git_access_token
  argocd_project_source_repo_url   = "https://github.com/iits-consulting/showcase-otc-infrastructure-charts.git"
  argocd_project_source_path       = "stages/dev/infrastructure-charts"  
}
```
