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
  description = "The Username of the Git User/Service account to be able to pull the git Code. If you use ssh key set it to \"\". This will disable token authentication"
  type        = string
  sensitive   = true
}

variable "argocd_git_access_token" {
  description = "Secret Access Token to be able to pull the git Code. If you use ssh key set it to \"\". This will disable token authentication"
  type        = string
  sensitive   = true
}

variable "argocd_git_access_private_key_base64Encoded" {
  description = "SSH Private Key to be able to pull the git Code. Default = \"\" which means it is disabled"
  type        = string
  sensitive   = true
  default     = ""
}

variable "argocd_project_source_repo_url" {
  description = "Git repository URL where the App of Apps Helm Chart resides."
  type        = string
}

variable "argocd_project_source_repo_branch" {
  description = "Git repository branch where the App of Apps Helm Chart resides."
  type        = string
  default     = "main"
}

variable "argocd_project_source_path" {
  description = "Path within the Git repository where the App of Apps Helm Chart resides."
  type        = string
}


variable "argocd_application_values" {
  description = "Helm Application Values and Secret which are handed down to ArgoCD"
  type        = any
  sensitive   = true
  default     = {}
}

variable "argocd_install_crds" {
  description = "If ArgoCD CRDs should be installed"
  type        = bool
  default     = false
}

variable "argocd_enable_server_side_apply" {
  description = "If k8s Server Side Apply should be enabled for this ArgoCD project."
  type        = bool
  default     = false
}