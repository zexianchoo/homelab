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

# resource "docker_image" "filestash_private" {
#   name = "machines/filestash:latest"
# }

# resource "docker_image" "sftp-server" {
#   name = "atmoz/sftp"
# }

resource "docker_container" "filestash_private" {
  name  = "filestash_private"
  image = "machines/filestash:latest"

  restart = "unless-stopped"
  ports {
    internal = 8334
    external = 8335
  }

  # user = "root"
  env = [
    "APPLICATION_URL=",
    "CANARY=true",
    "OFFICE_URL=http://localhost:9980",
    "OFFICE_FILESTASH_URL=http://localhost:8335",
    "OFFICE_REWRITE_URL=http://127.0.0.1:9980"
  ]

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes { 
    host_path = "${var.volume_path}/filestash_private/data"
    container_path = "/app/data/state/"
  }

#   depends_on = [
#     docker_container.sftp-server
#   ]
}

# resource "docker_container" "sftp-server" {
#   name  = "sftp-server"
#   image = docker_image.sftp-server.image_id

#   restart = "unless-stopped"

#   network_mode = "bridge"
#   networks_advanced {
#     name = var.network_name
#   }

#   volumes { 
#     host_path = "${var.volume_path}/filestash/sftp_config"
#     container_path = "/etc/sftp"
#     read_only = true
#   }

# }
