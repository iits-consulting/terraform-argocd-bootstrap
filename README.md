## Auto Create ArgoCD

Usage Example

```hcl
module "argocd" {
  source = "git::https://github.com/iits-consulting/terraform-argocd-bootstrap.git"
  argocd = {
    enabled                   = true
    stage                     = local.stage_name
    git_access_token_username = "ARGOCD_GIT_ACCESS_TOKEN"
    git_access_token          = var.argocd_git_access_token
    project_source_repo_url   = "https://github.com/iits-consulting/showcase-otc-infrastructure-charts.git"
    project_branch            = "main"
  }
  crds = {
    enabled                   = true
  }
  registry_creds = {
    enabled                          = true
    dockerconfig_json_base64_encoded = var.dockerconfig_json_base64_encoded
  }
}
```