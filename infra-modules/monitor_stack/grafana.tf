data "docker_registry_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_image" "grafana" {
  name          = data.docker_registry_image.grafana.name
  pull_triggers = [data.docker_registry_image.grafana.sha256_digest]
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  restart = "unless-stopped"

  ports {
    internal = 3000
    external = 9091
  }  

  env = [
    "GF_SECURITY_ADMIN_USER=${var.GRAFANA_ADMIN_USER}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.GRAFANA_ADMIN_PASS}"
  ]

  volumes {
    host_path = "${var.volume_path}/grafana/datasources"
    container_path = "/etc/grafana/provisioning/datasources"
  }

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

}
