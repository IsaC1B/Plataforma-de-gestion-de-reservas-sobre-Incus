variable "network_name" {
  description = "Red OVN del laboratorio"
  type        = string
  default     = "ovn-net"
}

variable "storage_pool" {
  description = "Pool de almacenamiento"
  type        = string
  default     = "default"
}

variable "base_image" {
  description = "Imagen de Defecto"
  type        = string
  default     = "images:ubuntu/24.04"
}
