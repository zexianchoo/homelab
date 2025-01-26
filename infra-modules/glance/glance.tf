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

resource "docker_image" "glance" {
  name = "glanceapp/glance"
}

resource "docker_container" "glance" {
  name  = "glance"
  image = docker_image.glance.image_id
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=Etc/UTC"
  ]

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8080
    external = 8080
  }

  restart = "unless-stopped"
  network_mode = "bridge"

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://glance:8080"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  # dns = []
  # domainname = ""

  volumes {
    host_path = "${var.volume_path}/glance/glance.yml"
    container_path = "/app/glance.yml"
  }  

  volumes {
    host_path = "/etc/localtime"
    container_path = "/etc/localtime"
  }  

  volumes {
    host_path = "/etc/timezone"
    container_path = "/etc/timezone"
  }  
}
