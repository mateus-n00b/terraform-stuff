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
    name =  "${kubernetes_service_account.helm_account.metadata.0.name}"
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

    depends_on = [
    "google_container_cluster.primary",
  ]

}
