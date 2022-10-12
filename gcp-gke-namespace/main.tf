data "google_container_cluster" "gke-terraform" {
  project  = var.project_id
  name     = var.cluster
  location = var.location
}

data "google_client_config" "default" {
}

resource "kubernetes_namespace" "gkenamespace" {
  for_each = var.nsname
  metadata {
    annotations = each.value.annotation
    labels      = each.value.labels
    name        = each.key
  }
}
