terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.65.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.65.0"
    }
  }
}
