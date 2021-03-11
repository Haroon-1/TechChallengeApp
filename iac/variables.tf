## Azure config variables ##
variable location {
  default = "australiaeast"
}

## Resource group variables ##
variable resource_group_name {
  default = "serviantechchallenge"
}

## ACR variables ##
variable acr_name {
  default = "servianacr"
}

## AKS kubernetes cluster variables ##
variable cluster_name {
  default = "k8-cluster-1"
}

variable "agent_count" {
  default = 2
}

variable "dns_prefix" {
  default = "k8"
}

variable "admin_username" {
    default = "hdogar"
}
