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

locals {
  argocd_settings = {
    logFormat = "json"
    env = [{
      name  = "TZ"
      value = "Europe/Berlin"
    }]
  }
  application_values = merge(var.argocd_application_values, {
    global = merge({
      projectName = var.argocd_project_name
      source = {
        appsBasePath   = "${var.argocd_project_source_path}/apps"
        repoURL        = var.argocd_project_source_repo_url
        targetRevision = var.argocd_project_source_repo_branch
      }
    }, lookup(var.argocd_application_values, "global", {}))
  })
}

resource "helm_release" "argocd" {
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
  values = [yamlencode({
    applicationValues = yamlencode(local.application_values)
    projects = {
      infrastructure = {
        name    = var.argocd_project_name
        repoUrl = var.argocd_project_source_repo_url
        path    = var.argocd_project_source_path
        branch  = var.argocd_project_source_repo_branch
      }
      gitToken = {
        name     = var.argocd_git_access_token_username
        password = var.argocd_git_access_token
      }
    }
    argo-cd = {
      notifications = {
        enabled = false
      }
      crds = {
        install = false
      }
      applicationSet = {
        enabled = false
      }
      controller = local.argocd_settings
      repoServer = local.argocd_settings
      dex        = local.argocd_settings
      server = merge(local.argocd_settings, {
        extraArgs = [
          "--insecure",
          "--rootpath=/argocd",
          "--basehref=/argocd",
        ]
      })
    }
    }
  )]
}