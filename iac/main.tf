## Azure resource provider ##
provider "azurerm" {
  features {}
}

## Azure resource group for the kubernetes cluster ##
resource "azurerm_resource_group" "techchallenge_k8" {
  name     = var.resource_group_name
  location = var.location
}

## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "techchallenge_k8" { 
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.techchallenge_k8.name
  location            = azurerm_resource_group.techchallenge_k8.location
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = var.admin_username

    ## SSH key is generated using "tls_private_key" resource
    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}
## ACR for uploading the container images ##
resource "azurerm_container_registry" "acr" {
  name                     = "servianacr"
  resource_group_name      = azurerm_resource_group.techchallenge_k8.name
  location                 = azurerm_resource_group.techchallenge_k8.location
  sku                      = "Basic"
  admin_enabled            = false
  georeplication_locations = ["Australia East"]
}

output "configure" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes client:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl

$ kubectl get nodes
CONFIGURE
}