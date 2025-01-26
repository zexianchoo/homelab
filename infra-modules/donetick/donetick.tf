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

resource "docker_image" "donetick" {
  name = "donetick/donetick"
}

resource "docker_container" "donetick" {
  name  = "donetick"
  image = docker_image.donetick.image_id

  env = [
          "DT_ENV=selfhosted",
          "DT_SQLITE_PATH=/donetick-data/donetick.db",
        ]

  ports {
    internal = 2021
    external = 2021
  }

  volumes {
    host_path = "${var.volume_path}/donetick/config"
    container_path = "/config"
  }

  volumes {
    host_path = "${var.volume_path}/donetick/data"
    container_path = "/donetick-data"
  }

}
