resource "helm_release" "crds" {
  count = var.crds.enabled ? 1 : 0
  name                  = "crds"
  repository            = "https://iits-consulting.github.io/crds-chart"
  chart                 = "crds"
  version               = var.crds.version
  namespace             = "crds"
  create_namespace      = true
  render_subchart_notes = true
  dependency_update     = true
}

resource "helm_release" "registry_creds" {
  count = var.registry_creds.enabled ? 1 : 0
  depends_on            = [helm_release.crds]
  name                  = "registry-creds"
  repository            = "https://iits-consulting.github.io/registry-creds-chart"
  chart                 = "registry-creds"
  version               = var.registry_creds.version
  namespace             = "registry-creds"
  create_namespace      = true
  atomic                = true
  render_subchart_notes = true
  dependency_update     = true
  set_sensitive {
    name  = "defaultClusterPullSecret.dockerConfigJsonBase64Encoded"
    value = var.registry_creds.dockerconfig_json_base64_encoded
  }
}

resource "helm_release" "argocd" {
  count = var.argocd.enabled ? 1 : 0
  depends_on            = [helm_release.registry_creds]
  name                  = "argocd"
  chart                 = "${path.module}/argocd"
  namespace             = "argocd"
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
        STAGE                     = var.argocd.stage
        PROJECT_NAME              = var.argocd.project_name
        GIT_ACCESS_TOKEN_USERNAME = var.argocd.git_access_token_username
        PROJECT_SOURCE_PATH       = var.argocd.project_source_path
        PROJECT_SOURCE_REPO_URL   = var.argocd.project_source_repo_url
        PROJECT_BRANCH            = var.argocd.project_branch
        GIT_ACCESS_TOKEN          = var.argocd.git_access_token
      }
    ))
  ]
}