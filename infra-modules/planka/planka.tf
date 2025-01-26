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

resource "docker_volume" "planka_db_data" {
  name = "planka_db_data"
}

resource "docker_image" "planka" {
  name = "ghcr.io/plankanban/planka:1.24.3"
}

resource "docker_image" "planka_db" {
  name = "postgres:16-alpine"
}

resource "docker_container" "planka" {
  name  = "planka"
  image = docker_image.planka.image_id

  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
      name = var.network_name
  }

  ports {
    internal = 1337
    external = 3000
  }

  env = [
      "BASE_URL=https://planka.${var.domain_name}",
      "DATABASE_URL=postgresql://postgres@planka_db/planka_db",
      "SECRET_KEY=${var.planka_secretkey}",
      "TRUST_PROXY=true",
      "DEFAULT_ADMIN_EMAIL=${var.planka_email}",
      "DEFAULT_ADMIN_PASSWORD=${var.planka_pass}",
      "DEFAULT_ADMIN_NAME=${var.planka_name}",
      "DEFAULT_ADMIN_USERNAME=${var.planka_username}",
  ]

  volumes {
      host_path = "${var.volume_path}/planka/user-avatars"
      container_path = "/app/public/user-avatars"
  } 
  volumes {
      host_path = "${var.volume_path}/planka/project-background-images"
      container_path = "/app/public/project-background-images"
  } 
  volumes {
      host_path = "${var.volume_path}/planka/attachments"
      container_path = "/app/private/attachments"
  }
  
  depends_on = [docker_container.planka_db]
}

resource "docker_container" "planka_db" {
  name  = "planka_db"
  image = docker_image.planka_db.image_id

  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
      name = var.network_name
  }

  env = [
      "POSTGRES_DB=planka_db",
      "POSTGRES_HOST_AUTH_METHOD=trust",
  ]

  volumes {
      # host_path = "${var.volume_path}/planka/data"
      volume_name = docker_volume.planka_db_data.name
      container_path = "/var/lib/postgresql/data"
  } 
  
}