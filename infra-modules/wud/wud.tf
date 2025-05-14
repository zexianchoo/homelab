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


resource "docker_image" "wud" {
  name = "getwud/wud"
}


resource "docker_container" "wud" {
  name  = "wud"
  image = docker_image.wud.image_id

  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
      name = var.network_name
  }

  volumes {
      host_path = "/var/run/docker.sock"
      container_path = "/var/run/docker.sock"
      read_only = true
  } 

  ports {
    internal = 3000
    external = 11300
  }

}