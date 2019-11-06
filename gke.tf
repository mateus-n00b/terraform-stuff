data "google_client_config" "current" {}

resource "google_container_cluster" "primary" {
  provider = "google-beta"
  name     = "${var.cluster_name.name}"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = false
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  provider = "google-beta"
  name       = "${var.node_pool_name}"
  location   = "${var.location}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    taint {
        effect = "NO_SCHEDULE"
        key = "type"
        # operator = "Equal"
        value  = "preemptible"
    }
    
    labels = {
        "preemptible" =  "true"
    }

    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"    ]
  }
}
