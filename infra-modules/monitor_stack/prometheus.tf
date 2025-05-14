terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}


data "docker_registry_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_image" "prometheus" {
  name          = data.docker_registry_image.prometheus.name
  pull_triggers = [data.docker_registry_image.prometheus.sha256_digest]
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  restart = "unless-stopped"

  ports {
    internal = 9090
    external = 9090
  }  
  
  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "${var.volume_path}/prometheus/config"
    container_path = "/etc/prometheus"
  } 
  
  # volumes {
  #   host_path = "${var.volume_path}/prometheus/data"
  #   container_path = "/prometheus"
  # }

}


data "docker_registry_image" "node_exporter" {
  name = "quay.io/prometheus/node-exporter:latest"
}

resource "docker_image" "node_exporter" {
  name          = data.docker_registry_image.node_exporter.name
  pull_triggers = [data.docker_registry_image.node_exporter.sha256_digest]
}

resource "docker_container" "node_exporter" {
  name  = "node_exporter"
  image = docker_image.node_exporter.image_id

  restart = "unless-stopped"
  
  ports {
    internal = 9100
    external = 9100
  }  

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "/"
    container_path = "/rootfs"
    read_only = true
  } 
  
  volumes {
    host_path = "/proc"
    container_path = "/host/proc"
    read_only = true
  }  

  volumes {
    host_path = "/sys"
    container_path = "/host/sys"
    read_only = true
  } 

  command = [
      "--web.listen-address=:9100",
      "--path.procfs=/host/proc",
      "--path.sysfs=/host/sys",
      "--path.rootfs=/rootfs",
      "--collector.tcpstat",
      "--collector.processes",
      "--collector.mountstats",
      "--collector.perf",
      "--collector.wifi",
  ]


}

data "docker_registry_image" "cadvisor" {
  name = "gcr.io/cadvisor/cadvisor:latest"
}

resource "docker_image" "cadvisor" {
  name          = data.docker_registry_image.cadvisor.name
  pull_triggers = [data.docker_registry_image.cadvisor.sha256_digest]
}

resource "docker_container" "cadvisor" {
  name  = "cadvisor"
  image = docker_image.cadvisor.image_id

  restart = "unless-stopped"
  
  ports {
    internal = 8080
    external = 9101
  }  

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "/"
    container_path = "/rootfs"
    read_only = true
  } 
  
  volumes {
    host_path = "/var/run"
    container_path = "/var/run"
    read_only = true
  }  

  volumes {
    host_path = "/sys"
    container_path = "/sys"
    read_only = true
  } 

  volumes {
    host_path = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only = true
  } 

  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only = true
  } 

}