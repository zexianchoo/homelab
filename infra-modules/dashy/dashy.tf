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
  registry_auth {
    address   = "registry-1.docker.io"
    username  = var.dockerhub_user
    password  = var.dockerhub_pass
  }
}

data "docker_registry_image" "dashy" {
  name = "lissy93/dashy:latest"
}

resource "docker_image" "dashy" {
  name          = data.docker_registry_image.dashy.name
  pull_triggers = [data.docker_registry_image.dashy.sha256_digest]
}

resource "docker_container" "dashy" {
  name  = "dashy"
  image = docker_image.dashy.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }
  env = [ "NODE_ENV=production" ]
  ports {
    internal = 8080
    external = 4000
  }

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:8080"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    host_path = "${var.volume_path}/dashy/config"
    container_path = "/app/user-data"
  }    

  volumes {
    host_path = "${var.volume_path}/dashy/icons"
    container_path = "/app/public/item-icons"
  }      
  
  # volumes {
  #   host_path = "${var.volume_path}/dashy/favicon.ico"
  #   container_path = "/app/public/favicon.ico"
  # }    
}
