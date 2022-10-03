################################################################################
# LZ service-account workload identities                                       #
################################################################################
provider "kubernetes" {
  load_config_file = "false"
}

resource "kubernetes_namespace" "bu_namespace" {
  metadata {
    name   = "lz-bu-${var.unit_code}"
    labels = { unit = var.unit_code }
  }
}

resource "kubernetes_service_account" "lz_folder_sa" {
  for_each = local.environments
  metadata {
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
    name      = "lz-bu-${var.unit_code}-${each.key}-master"
    annotations = {
      "iam.gke.io/gcp-service-account" : google_service_account.environment[each.key].email
    }
    labels = { unit = var.unit_code, sdlc = each.key }
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "lz_svpc_sa" {
  for_each = local.shared_vpc_hosts
  metadata {
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
    name      = module.env_svpc_hosts[each.key].project_id
    annotations = {
      "iam.gke.io/gcp-service-account" : module.env_svpc_automation_service_accounts[each.key].email
    }
    labels = {
      unit    = var.unit_code,
      sdlc    = each.key,
      project = module.env_svpc_hosts[each.key].project_id
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "lz_images_sa" {
  metadata {
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
    name      = module.images_project.project_id
    annotations = {
      "iam.gke.io/gcp-service-account" : module.images_automation_service_account.email
    }
    labels = {
      unit    = var.unit_code,
      sdlc    = "prod",
      project = module.images_project.project_id
    }
  }
  automount_service_account_token = true
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each           = local.environments
  service_account_id = google_service_account.environment[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.global_automation_project_id}.svc.id.goog[lz-bu-${var.unit_code}/lz-bu-${var.unit_code}-${each.key}-master]"
}

resource "kubernetes_role_binding" "jenkins_agent" {
  metadata {
    name      = "jenkins-agent"
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "jenkins"
    namespace = "jenkins"
  }
}

resource "kubernetes_role" "environment_agent" {
  metadata {
    name      = "lz-env-agent"
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "secrets"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}

resource "kubernetes_role_binding" "lz_env_agent" {
  metadata {
    name      = "lz-env-agents"
    namespace = kubernetes_namespace.bu_namespace.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.environment_agent.metadata.0.name
  }
  dynamic "subject" {
    for_each = local.kubernetes_sa_metadata
    content {
      kind      = "ServiceAccount"
      namespace = subject.value["namespace"]
      name      = subject.value["name"]
    }
  }
}
