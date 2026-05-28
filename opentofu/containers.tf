resource "incus_instance" "node_control" {
  name     = "node-control"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.base.name]

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
      network        = var.network_name
      "ipv4.address" = "10.10.0.2"
    }
  }

  depends_on = [incus_profile.base]
}

resource "incus_instance" "app_api" {
  name     = "app-api"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.base.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = "10.10.0.3"
    }
  }

  depends_on = [incus_profile.base]
}

resource "incus_instance" "app_core" {
  name     = "app-core"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.base.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = "10.10.0.4"
    }
  }

  depends_on = [incus_profile.base]
}

resource "incus_instance" "db_postgres" {
  name     = "db-postgres"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.db.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = "10.10.0.5"
    }
  }

  depends_on = [incus_profile.db]
}

resource "incus_instance" "monitoring" {
  name     = "monitoring"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.monitoring.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = "10.10.0.6"
    }
  }

  depends_on = [incus_profile.monitoring]
}

resource "incus_instance" "ceph_node" {
  name     = "ceph-node"
  image    = var.base_image
  type     = "container"
  running  = true
  profiles = [incus_profile.ceph.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = "10.10.0.7"
    }
  }

  depends_on = [incus_profile.ceph]
}

output "lab_ips" {
  value = {
    node_control = "10.10.0.2"
    app_api      = "10.10.0.3"
    app_core     = "10.10.0.4"
    db_postgres  = "10.10.0.5"
    monitoring   = "10.10.0.6"
    ceph_node    = "10.10.0.7"
  }
}
