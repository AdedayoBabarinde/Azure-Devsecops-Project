variable "name" {
  description = "Globally unique name of the Azure Container Registry"
  type        = string

}
variable "location" {
  description = "Azure Region"
  type        = string

}

variable "resource_group_name" {
  description = "Name of the Resource group"
  type        = string

}
variable "node_count" {
  description = "Number of Nodes in the default node pool"
  type        = number
}
variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "standard_DS2_v2"

}
variable "environment" {
  description = "Environment label for tagging (e.g., dev, stage, prod)"
  type        = string

}
variable "owner" {
  description = "Tag to indicate owner"
  type        = string

}
variable "acr_name" {
  description = "Name of the ACR"
  type        = string

}
variable "aks_name" {
  description = "Name of the AKS"
  type        = string

}
