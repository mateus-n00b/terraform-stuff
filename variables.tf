variable "project" {
  default = "sublime-lodge-256822"
}

variable "region" {
  default = "us-central"
}

variable "config_file" {
  default = "config/kube-config.yaml"
}

variable "location" {
  default = "us-central1"
}

variable "cluster_name" {
  type = "map"
  default = {
      name = "eisa"
  }
}


variable "node_pool_name" {
  default = "eisa-cluster"
}

variable "helm_version" {
  default = "v2.16.0-rc.2"
}
