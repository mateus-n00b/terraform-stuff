provider "google" {
    credentials = "${file("config/compute.json")}"
    project =  "${var.project}"
    region  = "${var.region}"
}

provider "google-beta" {
    credentials = "${file("config/default.json")}"
    project =  "${var.project}"
    region  = "${var.region}"
}

provider "kubernetes" {    
    load_config_file = false
    host                   = "${google_container_cluster.primary.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"         
}

provider "helm" {  
  service_account = "${kubernetes_service_account.helm_account.metadata.0.name}"
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.helm_version}"         

  kubernetes {
        load_config_file = false
    host                   = "${google_container_cluster.primary.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"         
      
  }
}
