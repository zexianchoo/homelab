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
resource "docker_network" "homelab" {
  name = "homelab_network"
}

output "network_name" {
  value = docker_network.homelab.name
  description = "Name of the homelab docker network"
}
