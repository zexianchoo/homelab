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

resource "docker_image" "nextcloud" {
  name = "nextcloud:latest"
}

resource "docker_image" "nextcloud_db" {
  name = "mariadb:11.2"
}

resource "docker_image" "nextcloud_redis" {
  name = "redis"
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
    "NEXTCLOUD_TRUSTED_DOMAINS:seanchoo.top nextcloud.seanchoo.top www.nextcloud.seanchoo.top https://nextcloud.seanchoo.top",
    # "OVERWRITEPROTOCOL=https",
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
