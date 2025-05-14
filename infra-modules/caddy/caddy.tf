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

resource "docker_image" "caddy" {
  # name = "caddy:2.9.1"
  name = "caddybuilds/caddy-cloudflare:latest"
}

resource "docker_container" "caddy" {
  name  = "caddy"
  image = docker_image.caddy.image_id
  restart = "unless-stopped"
  capabilities {
    add = ["NET_ADMIN"]
  }

  env = [
    "CLOUDFLARE_API_TOKEN=${var.cloudflare_api_token}"
  ]
  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 443
    external = 443
    protocol = "udp"
  }

  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:80"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "${var.volume_path}/caddy/caddy_data"
    container_path = "/data"
  } 
  
  volumes {
    host_path = "${var.volume_path}/caddy/config"
    container_path = "/config"
  } 
  
  volumes {
    host_path = "${var.volume_path}/caddy/site"
    container_path = "/srv"
  }    
  
  volumes { 
    host_path = "${var.volume_path}/caddy/caddystuff"
    container_path = "/etc/caddy"
  }

  # adds caddy security package
  # command = [
  #   "sh", "-c", "caddy add-package github.com/greenpau/caddy-security && caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"
  # ]

}
