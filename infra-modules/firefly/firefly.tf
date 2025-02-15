terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly/.env")) : tuple[0] => sensitive(tuple[1]) }
  db_envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly/.db.env")) : tuple[0] => sensitive(tuple[1]) }
}
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "firefly" {
  name = "fireflyiii/core:latest"
}

resource "docker_container" "firefly" {
  name  = "firefly"
  image = docker_image.firefly.image_id
  env   = [for key, value in local.envs : "${key}=${value}"]

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8080
    external = 12321
  }

  restart = "unless-stopped"
  network_mode = "bridge"

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:8080"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    host_path      = "${var.volume_path}/firefly/upload"
    container_path = "/var/www/html/storage/upload"
  }
  depends_on = [docker_container.firefly_db]
}

resource "docker_image" "firefly_mariadb_img" {
  name = "mariadb:11.2"
}
resource "docker_container" "firefly_db" {
  name         = "firefly_db"
  image        = docker_image.firefly_mariadb_img.image_id
  hostname     = "db"
  restart      = "always"
  network_mode = "bridge"
  # user = "root"
  networks_advanced {
    name = var.network_name
  }
  volumes {
    host_path      = "${var.volume_path}/firefly/db"
    container_path = "/var/lib/mysql"
  }
  env   = [for key, value in local.db_envs : "${key}=${value}"]
}

# resource "docker_image" "firefly_cron_img" {
#   name = "alpine"
# }
# resource "docker_container" "firefly_cron" {
#   name         = "firefly_cron"
#   image        = docker_image.firefly_cron_img.image_id
#   restart      = "unless-stopped"
#   network_mode = "bridge"
#   networks_advanced {
#     name = var.network_name
#   }
  # command = [ <<EOL
  #   sh -c "
  #     apk add tzdata
  #     && ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
  #     | echo \"0 3 * * * wget -qO- http://app:8080/api/v1/cron/REPLACEME;echo\" 
  #     | crontab - 
  #     && crond -f -L /dev/stdout"
  # EOL]
# }
