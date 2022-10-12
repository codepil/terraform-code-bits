provider "google" {
  #  credentials = file("creds/serviceaccount.json")
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.gke-terraform.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.gke-terraform.master_auth[0].cluster_ca_certificate,
  )
}
