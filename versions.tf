terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    errorcheck = {
      source = "iits-consulting/errorcheck"
    }
  }
}
