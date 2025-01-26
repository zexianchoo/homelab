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

resource "docker_image" "nginx-proxy-manager" {
  name = "docker.io/jc21/nginx-proxy-manager:latest"
}

resource "docker_container" "nginx-proxy-manager" {
  name  = "nginx-proxy-manager"
  image = docker_image.nginx-proxy-manager.image_id

  restart = "unless-stopped"

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 81
    external = 81
  }
  network_mode = "bridge"
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:81"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "${var.volume_path}/nginx-proxy-manager/data"
    container_path = "/data"
  } 
  
  volumes {
    host_path = "${var.volume_path}/nginx-proxy-manager/letsencrypt"
    container_path = "/etc/letsencrypt"
  }    
}
