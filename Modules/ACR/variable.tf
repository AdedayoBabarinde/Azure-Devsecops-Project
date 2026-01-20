variable "name" {
  description = "Globally unique name of the Azure Container Registry"
  type = string

}
variable "location" {
  description = "Azure Region"
  type = string
  
}
variable "resource_group_name" {
  description = "Name of the Resource group"
  type = string
  
}