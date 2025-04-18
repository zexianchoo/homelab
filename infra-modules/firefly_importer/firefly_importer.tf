terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  envs = { 
    for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly_importer/.env")) : tuple[0] => sensitive(tuple[1])
  }
  
  importer_envs = { 
    for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly_importer/.importer.env")) : tuple[0] => sensitive(tuple[1])
  }
  
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "firefly_importer" {
  name = "fireflyiii/data-importer:latest"
}

resource "docker_image" "firefly_iii_db" {
  name = "mariadb:lts"
}

resource "docker_image" "firefly_iii_db" {
  name = "mariadb:lts"
}

resource "docker_container" "firefly_importer" {
  name  = "firefly_importer"
  image = docker_image.firefly_importer.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  env = [
    for key, value in local.importer_envs : "${key}=${value}",
    firefly_random_root_password = ${var.firefly_random_root_password}
    firefly_mysql_user = ${var.firefly_mysql_user}
    firefly_mysql_password = ${var.firefly_mysql_password}
    firefly_mysql_database = ${var.firefly_mysql_database}
  ]

  # ports {
  #   internal = 8080
  #   external = 8080
  # }

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:8081"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    host_path = "${var.volume_path}/homer-public/config"
    container_path = "/www/assets"
  }    
}
