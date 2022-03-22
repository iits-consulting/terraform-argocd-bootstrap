### CRD collection Configuration:
variable "custom_resource_definitions_enabled" {
  description = "Enable or disable the CRD collection chart. (default: false)"
  type        = bool
  default     = false
}

variable "custom_resource_definitions_version" {
  description = "Version of CRD collection chart. (default: 1.1.3)"
  type        = string
  default     = "1.1.3"
}

variable "custom_resource_definitions_namespace" {
  description = "Kubernetes namespace to install CRD collection chart to. (default: crds)"
  type        = string
  default     = "crds"
}

### Registry Credentials Configuration:
variable "registry_credentials_enabled" {
  description = "Enable or disable the Registry Credentials chart. (default: false)"
  type        = bool
  default     = false
}

variable "registry_credentials_version" {
  description = "Version of Registry Credentials chart. (default: 1.0.6)"
  type        = string
  default     = "1.0.6"
}

variable "registry_credentials_namespace" {
  description = "Kubernetes namespace to install Registry Credentials chart to. (default: registry-creds)"
  type        = string
  default     = "registry-creds"
}

variable "registry_credentials_dockerconfig" {
  description = "Dockerconfig in kubernetes.io/dockerconfigjson format. See https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/"
  type        = string
  default     = ""
  sensitive   = true
}

resource "errorcheck_is_valid" "registry_credentials_dockerconfig_validation" {
  name = "Registry Credentials Dockerconfig Validation"
  test = {
    assert        = can([for value in values(jsondecode(base64decode(var.registry_credentials_dockerconfig))["auths"]) : base64decode(value["auth"])]) || !var.registry_credentials_enabled
    error_message = "The variable registry_credentials_dockerconfig is empty or not in kubernetes.io/dockerconfigjson format!"
  }
}

### ArgoCD Configuration:
variable "argocd_enabled" {
  description = "Enable or disable the ArgoCD chart. (default: true)"
  type        = bool
  default     = true
}

variable "argocd_namespace" {
  description = "Kubernetes namespace to install ArgoCD chart to. (default: argocd)"
  type        = string
  default     = "argocd"
}

variable "argocd_project_name" {
  description = "The ArgoCD project name shown in the UI (default: infrastructure-charts)"
  type        = string
  default     = "infrastructure-charts"
}

variable "argocd_git_access_token_username" {
  description = "The Username of the Git User/Service account to be able to pull the git Code."
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_git_access_token" {
  description = "Secret Access Token to be able to pull the git Code."
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_project_source_repo_url" {
  description = "Git repository URL where the App of Apps Helm Chart resides."
  type        = string
  default     = ""
}

variable "argocd_project_source_repo_branch" {
  description = "Git repository branch where the App of Apps Helm Chart resides."
  type        = string
  default     = "main"
}

variable "argocd_project_source_path" {
  description = "Path within the Git repository where the App of Apps Helm Chart resides."
  type        = string
  default     = ""
}

resource "errorcheck_is_valid" "argocd_validation" {
  for_each = {
    argocd_namespace                  = var.argocd_namespace
    argocd_project_name               = var.argocd_project_name
    argocd_git_access_token_username  = var.argocd_git_access_token_username
    argocd_git_access_token           = var.argocd_git_access_token
    argocd_project_source_repo_url    = var.argocd_project_source_repo_url
    argocd_project_source_repo_branch = var.argocd_project_source_repo_branch
    argocd_project_source_path        = var.argocd_project_source_path
  }
  name = "ArgoCD ${title(join(" ", split("_", replace(each.key, "argocd_", ""))))} Validation"
  test = {
    assert        = length(each.value) != 0 || !var.argocd_enabled
    error_message = "The variable ${each.key} can not be empty if ArgoCD is enabled!"
  }
}

resource "errorcheck_is_valid" "argocd_project_source_repo_url_validation" {
  name = "ArgoCD Project Source Repo URL Validation"
  test = {
    assert        = length(var.argocd_project_source_repo_url) == 0 || substr(var.argocd_project_source_repo_url, 0, 8) == "https://" || !var.argocd_enabled
    error_message = "Only https is supported for argocd_project_source_repo_url!"
  }
}
