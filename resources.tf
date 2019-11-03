resource "helm_release" "myapp" {
  name  = "myapp"
  chart = "./charts/myapp"
  timeout    = 1200
  namespace = "eisa-prod"  
  depends_on = ["google_container_node_pool.primary_preemptible_nodes"]
}

data "google_client_config" "current" {}

resource "kubernetes_service_account" "helm_account" {
  depends_on = [
    "google_container_cluster.primary",
  ]
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}


resource "kubernetes_cluster_role_binding" "tiller" {
  
  metadata {
    name =  "${kubernetes_service_account.tiller.metadata.0.name}"
  }
  role_ref {
    # api_group = ["rbac.authorization.k8s.io", "apps" , "extensions", " "]
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
    api_group = ""
  }
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "http://storage.googleapis.com/kubernetes-charts-incubator"
}

resource "helm_release" "kubedownscale" {
  repository = "https://kubernetes-charts-incubator.storage.googleapis.com"
  name = "downscale"
  chart = "kube-downscaler"
  namespace = "default"
  timeout = 1200

#   set {
#       name = "nodeSelector.preemptible"
#       value = "true"
#   }

    depends_on = ["google_container_node_pool.primary_preemptible_nodes"]
#   set {
#       name = "taint"
#       value = ""
#   }
}


# resource "google_project" "eisa_project" {
#   name = "eisa-project"
#   project_id = "32320303"
#   org_id     = "1234567"
# }


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
