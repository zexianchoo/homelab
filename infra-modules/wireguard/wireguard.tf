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

resource "docker_image" "wireguard" {
  name = "lscr.io/linuxserver/wireguard:latest"
}

resource "docker_container" "wireguard" {
  name  = "wireguard"
  image = docker_image.wireguard.image_id

  capabilities {
    add = ["NET_ADMIN", "SYS_MODULE"]
  }
  network_mode = "bridge"
  
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=Etc/UTC",
    "SERVERURL=vpn.${var.domain_name}",
    "SERVERPORT=51820",
    "PEERS=1",
    "PEERDNS=auto",
    "INTERNAL_SUBNET=10.13.13.0",
    "ALLOWEDIPS=0.0.0.0/0",
    "PERSISTENTKEEPALIVE_PEERS=",
    "LOG_CONFS=true"
  ]

  volumes {
    host_path    = "${var.volume_path}/wireguard/config"
    container_path = "/config"
  }

  volumes {
    host_path    = "/lib/modules"
    container_path = "/lib/modules"
  }

  ports {
    internal = 51820
    external = 51820
    protocol = "udp"
  }

  sysctls = {
    "net.ipv4.conf.all.src_valid_mark" = 1
  }

  restart = "unless-stopped"
}