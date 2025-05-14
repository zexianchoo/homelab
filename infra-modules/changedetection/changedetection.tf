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


data "docker_registry_image" "change_detection" {
  name = "ghcr.io/dgtlmoon/changedetection.io:latest"
}

resource "docker_image" "change_detection" {
  name          = data.docker_registry_image.change_detection.name
  pull_triggers = [data.docker_registry_image.change_detection.sha256_digest]
}

resource "docker_container" "change_detection" {
  name  = "change_detection"
  image = docker_image.change_detection.image_id

  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
      name = var.network_name
  }

  ports {
    internal = 5000
    external = 11500
  }


  env = [
      "BASE_URL=https://changedetection.${var.domain_name}",
      "PLAYWRIGHT_DRIVER_URL=ws://browserless:3000",
      "PUID=1000",
      "PGID=1000",
      "TZ=America/Chicago",
  ]

  volumes {
    host_path      = "${var.volume_path}/changedetection/data"
    container_path = "/datastore"
  }

  depends_on = [docker_container.browserless]
}

data "docker_registry_image" "browserless" {
  name = "dgtlmoon/sockpuppetbrowser:latest"
}

resource "docker_image" "browserless" {
  name          = data.docker_registry_image.browserless.name
  pull_triggers = [data.docker_registry_image.browserless.sha256_digest]
}


resource "docker_container" "browserless" {
  name  = "browserless"
  image = docker_image.browserless.image_id

  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
      name = var.network_name
  }

  ports {
    internal = 3000
    external = 3000
  }

    ports {
    internal = 8080
    external = 11501
  }

  env = [
    "DEFAULT_LAUNCH_ARGS=[\"--window-size=1920,1080\"]",
    "MAX_CONCURRENT_CHROME_PROCESSES=1"
  ]
}
