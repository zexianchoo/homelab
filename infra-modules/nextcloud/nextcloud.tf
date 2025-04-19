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


data "docker_registry_image" "nextcloud" {
  name = "nextcloud:latest"
}

resource "docker_image" "nextcloud" {
  name          = data.docker_registry_image.nextcloud.name
  pull_triggers = [data.docker_registry_image.nextcloud.sha256_digest]
}

data "docker_registry_image" "nextcloud_db" {
  name = "public.ecr.aws/docker/library/mariadb:latest"
  # name = "mariadb:latest"
}

resource "docker_image" "nextcloud_db" {
  name          = data.docker_registry_image.nextcloud_db.name
  pull_triggers = [data.docker_registry_image.nextcloud_db.sha256_digest]
}


data "docker_registry_image" "nextcloud_redis" {
  name = "redis:latest"
}

resource "docker_image" "nextcloud_redis" {
  name          = data.docker_registry_image.nextcloud_redis.name
  pull_triggers = [data.docker_registry_image.nextcloud_redis.sha256_digest]
}

resource "docker_container" "nextcloud_db" {
  name  = "nextcloud_db"
  image = docker_image.nextcloud_db.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.nextcloud_db_root_password}",
    "MYSQL_PASSWORD=${var.nextcloud_db_password}",
    "MYSQL_DATABASE=${var.nextcloud_db_database}",
    "MYSQL_USER=${var.nextcloud_db_user}",
  ]

  volumes {
    host_path = "${var.volume_path}/nextcloud/nextcloud_db"
    container_path = "/var/lib/mysql"
  }    

  command = ["--transaction-isolation=READ-COMMITTED", "--log-bin=binlog", "--binlog-format=ROW"]
}

resource "docker_container" "nextcloud_redis" {
  name  = "nextcloud_redis"
  image = docker_image.nextcloud_redis.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path = "${var.volume_path}/nextcloud/nextcloud_redis"
    container_path = "/data"
  }    

  depends_on = [
    docker_container.nextcloud_db,
  ]
}

resource "docker_container" "nextcloud" {
  name  = "nextcloud"
  image = docker_image.nextcloud.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 80
    external = 9001
  }

  env = [
    "MYSQL_HOST=nextcloud_db",
    "MYSQL_PASSWORD=${var.nextcloud_db_password}",
    "MYSQL_DATABASE=${var.nextcloud_db_database}",
    "MYSQL_USER=${var.nextcloud_db_user}",
    "REDIS_HOST=nextcloud_redis",
    "TRUSTED_PROXIES=0.0.0.0",
    "OVERWRITEPROTOCOL=https"
  ]
  # user = "root"
  volumes {
    host_path = "${var.volume_path}/nextcloud/nextcloud_data"
    container_path = "/var/www/html"
  }    

  depends_on = [
    docker_container.nextcloud_db,
    docker_container.nextcloud_redis
  ]
}
