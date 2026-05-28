terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = ">= 0.3.0"
    }
  }
}

provider "incus" {
  accept_remote_certificate = true
}
