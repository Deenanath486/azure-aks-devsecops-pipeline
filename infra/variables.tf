variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg-aks-devsecops-prod"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "centralindia"
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
  default     = "aks-devsecops-cluster"
}

variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric)"
  default     = "acrdevsecopsenterprise"
}

variable "node_count" {
  type        = number
  description = "Default node pool count"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "VM SKU for the default AKS node pool"
  default     = "Standard_D2s_v3"
}

variable "environment" {
  type        = string
  description = "Environment identifier"
  default     = "production"
}
