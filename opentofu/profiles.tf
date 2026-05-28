resource "incus_profile" "base" {
  name        = "lab-base"
  description = "Perfil base para todos los nodos del laboratorio"

  config = {
    "limits.cpu"    = "1"
    "limits.memory" = "512MB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = var.storage_pool
      path = "/"
      size = "8GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
    }
  }
}

resource "incus_profile" "db" {
  name        = "lab-db"
  description = "Perfil para PostgreSQL - mas memoria y disco"

  config = {
    "limits.cpu"    = "1"
    "limits.memory" = "1024MB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = var.storage_pool
      path = "/"
      size = "12GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
    }
  }
}

resource "incus_profile" "monitoring" {
  name        = "lab-monitoring"
  description = "Perfil para Prometheus y Grafana"

  config = {
    "limits.cpu"    = "1"
    "limits.memory" = "1024MB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = var.storage_pool
      path = "/"
      size = "10GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
    }
  }
}

resource "incus_profile" "ceph" {
  name        = "lab-ceph"
  description = "Perfil para nodo Ceph con privilegios"

  config = {
    "limits.cpu"          = "1"
    "limits.memory"       = "512MB"
    "security.privileged" = "true"
    "security.nesting"    = "true"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = var.storage_pool
      path = "/"
      size = "10GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
    }
  }
}
