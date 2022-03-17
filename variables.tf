variable "crds" {
  description = "iits CRDs configuration parameters"
  type = object({
    enabled = optional(bool)   // Enabled deployment
    version = optional(string) // Helm Chart Version (default 1.1.3)
  })
}

locals {
  crds = defaults(var.crds, {
    enabled = true
    version = "1.1.3"
  })
}

variable "registry_creds" {
  description = "Registry-Creds configuration parameters"
  sensitive   = true
  type = object({
    enabled                          = optional(bool)   // Enabled deployment
    version                          = optional(string) // Helm Chart Version (default 1.0.6)
    dockerconfig_json_base64_encoded = string           // Dockerconfig to inject pull secret into every kubernetes deployment. See also https://github.com/iits-consulting/registry-creds-chart
  })
  #TODO add base64 validation
}

locals {
  registry_creds = defaults(var.registry_creds, {
    enabled = true
    version = "1.0.6"
  })
}

variable "argocd" {
  description = "ArgoCD configuration parameters"
  sensitive   = true
  type = object({
    enabled                   = optional(bool)   // Enabled deployment
    stage                     = string           // Is needed for the Sync Window to auto apply changes on production only after 18:00
    project_name              = optional(string) // The ArgoCD project name shown in the UI (default: infrastructure-charts)
    git_access_token_username = string           // The Username of the Git User/Service account/Token to be able to pull the git Code
    git_access_token          = string           // Secret Access Token to be able to pull the git code
    project_source_path       = optional(string) // The Path to the App of Apps Helm Chart (default: stages/${var.argocd.stage}/infrastructure-charts)
    project_source_repo_url   = string           // Git URL to the Boostrap Git Repo where the App of Apps Helm Chart resides
    project_branch            = string           // Git Repo branch name
  })
  validation {
    condition     = substr(var.argocd.project_source_repo_url, 0, 5) == "https"
    error_message = "Only https is supported for project_source_repo_url !"
  }
}

locals {
  argocd = defaults(var.argocd, {
    enabled = true
    project_name        = "infrastructure-charts"
    project_source_path = "stages/${var.argocd.stage}/infrastructure-charts"
  })
}