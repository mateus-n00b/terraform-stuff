resource "helm_release" "myapp" {
  name  = "myapp"
  chart = "./charts/myapp"
  timeout    = 1200
  namespace = "eisa-prod"  
  depends_on = ["google_container_node_pool.primary_preemptible_nodes"]
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