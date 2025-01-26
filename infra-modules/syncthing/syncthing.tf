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

resource "docker_image" "syncthing" {
  name = "syncthing/syncthing:latest"
}

resource "docker_container" "syncthing" {
  name  = "syncthing"
  image = docker_image.syncthing.image_id

  restart = "unless-stopped"
  env = [
    "PUID=1000",
    "PGID=1000",
  ]
  ports {
    internal = 8384
    external = 8384
  }  
  
  ports {
    internal = 22000
    external = 22000
    protocol = "tcp"
  }  

  ports {
    internal = 22000
    external = 22000
    protocol = "udp"
  }  
  
  ports {
    internal = 21027
    external = 21027
    protocol = "udp"
  }

  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "${var.volume_path}/syncthing/data"
    container_path = "/var/syncthing"
  } 
}
