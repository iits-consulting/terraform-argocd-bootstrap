resource "helm_release" "custom_resource_definitions" {
  count                 = var.custom_resource_definitions_enabled ? 1 : 0
  name                  = "crds"
  repository            = "https://iits-consulting.github.io/crds-chart"
  chart                 = "crds"
  version               = var.custom_resource_definitions_version
  namespace             = var.custom_resource_definitions_namespace
  create_namespace      = true
  render_subchart_notes = true
  dependency_update     = true
}

resource "helm_release" "registry_credentials" {
  count                 = var.registry_credentials_enabled ? 1 : 0
  depends_on            = [helm_release.custom_resource_definitions]
  name                  = "registry-creds"
  repository            = "https://iits-consulting.github.io/registry-creds-chart"
  chart                 = "registry-creds"
  version               = var.registry_credentials_version
  namespace             = var.registry_credentials_namespace
  create_namespace      = true
  atomic                = true
  render_subchart_notes = true
  dependency_update     = true
  set_sensitive {
    name  = "defaultClusterPullSecret.dockerConfigJsonBase64Encoded"
    value = var.registry_credentials_dockerconfig
  }
}

resource "helm_release" "argocd" {
  count                 = var.argocd_enabled ? 1 : 0
  depends_on            = [helm_release.registry_credentials]
  name                  = "argocd"
  chart                 = "${path.module}/argocd"
  namespace             = var.argocd_namespace
  create_namespace      = true
  wait                  = true
  atomic                = true
  timeout               = 900 // 15 Minutes
  render_subchart_notes = true
  dependency_update     = true
  wait_for_jobs         = true
  values = [
    sensitive(templatefile(
      "${path.module}/argocd/values.yaml",
      {
        PROJECT_NAME              = var.argocd_project_name
        GIT_ACCESS_TOKEN_USERNAME = var.argocd_git_access_token_username
        PROJECT_SOURCE_PATH       = var.argocd_project_source_path
        PROJECT_SOURCE_REPO_URL   = var.argocd_project_source_repo_url
        PROJECT_BRANCH            = var.argocd_project_source_repo_branch
        GIT_ACCESS_TOKEN          = var.argocd_git_access_token
      }
    ))
  ]
}