locals {
  argocd_settings = {
    logFormat = "json"
    env = [{
      name  = "TZ"
      value = "Europe/Berlin"
      },
      {
        name  = "ARGOCD_GPG_ENABLED"
        value = "false"
      },
    ]
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
        name            = var.argocd_project_name
        repoUrl         = var.argocd_project_source_repo_url
        path            = var.argocd_project_source_path
        branch          = var.argocd_project_source_repo_branch
        serverSideApply = var.argocd_enable_server_side_apply
      }
      gitToken = {
        name     = var.argocd_git_access_token_username
        password = var.argocd_git_access_token
      }
      repoPrivateKeyBase64Encoded = var.argocd_git_access_private_key_base64Encoded
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