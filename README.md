# Deprecated

We simplified the terraform module so that we don't need a module anymore.

Now you need only to install this helm chart: https://github.com/iits-consulting/charts/tree/main/charts/argocd

Usage example:

```hcl
resource "helm_release" "argocd" {
  name                  = "argocd"
  repository            = "https://charts.iits.tech"
  chart                 = "argocd"
  version               = "5.22.1"
  namespace             = "argocd"
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values                = [
    yamlencode({
      projects = {
        infrastructure-charts = {
          projectValues = {
            # Set this to enable stage $STAGE-values.yaml
            stage        = var.stage
            # Example values which are handed down to the project. Like this you can give over informations from terraform to argocd
            traefikElbId = module.terraform_secrets_from_encrypted_s3_bucket.secrets["elb_id"]
            adminDomain  = "admin.${var.domain_name}"
          }

          git = {
            password = var.git_token
            repoUrl  = var.argocd_bootstrap_project_url
          }
        }
      }
    }
    )
  ]
}
```

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
