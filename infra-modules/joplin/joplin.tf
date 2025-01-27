terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_volume" "joplin_db_volume" {
  name = "joplin_db_data"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "joplin" {
  name = "joplin/server:latest"
}

resource "docker_image" "joplin_db" {
  name = "postgres:16"
}

  resource "docker_container" "joplin_db" {
    name  = "joplin_db"
    image = docker_image.joplin_db.image_id

    restart = "unless-stopped"
    network_mode = "bridge"
    networks_advanced {
      name = var.network_name
    }
    env = [
      "POSTGRES_PASSWORD=${var.joplin_db_password}",
      "POSTGRES_USER=${var.joplin_db_user}",
      "POSTGRES_DB=${var.joplin_db_database}",
    ]

    volumes {
      # host_path = "${var.volume_path}/joplin/data"
      volume_name = docker_volume.joplin_db_volume.name
      container_path = "/var/lib/postgresql"
    }    
}

resource "docker_container" "joplin" {
  name  = "joplin"
  image = docker_image.joplin.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 22300
    external = 22300
  }

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:22300"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  env = [
    "APP_PORT=22300",
    "APP_BASE_URL=https://joplin.${var.domain_name}",
    "DB_CLIENT=pg",
    "POSTGRES_PASSWORD=${var.joplin_db_password}",
    "POSTGRES_DATABASE=${var.joplin_db_database}",
    "POSTGRES_USER=${var.joplin_db_user}",
    "POSTGRES_PORT=5432",
    "POSTGRES_HOST=joplin_db",
  ]

  depends_on = [
    docker_container.joplin_db
  ]
}