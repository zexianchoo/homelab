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

data "docker_registry_image" "filestash" {
  name = "machines/filestash:latest"
}

resource "docker_image" "filestash" {
  name          = data.docker_registry_image.filestash.name
  pull_triggers = [data.docker_registry_image.filestash.sha256_digest]
}

resource "docker_image" "sftp-server" {
  name = "atmoz/sftp"
}

# resource "docker_image" "wopi" {
#   name = "collabora/code:24.04.10.2.1"
# }

# resource "docker_container" "wopi" {
#   name  = "wopi"
#   image = docker_image.wopi.image_id

#   restart = "unless-stopped"

#   env = [
#     "extra_params=--o:ssl.enable=false",
#     "aliasgroup1=https://.*:443"
#   ]

#   network_mode = "bridge"
#   networks_advanced {
#     name = var.network_name
#   }
#   ports {
#     internal = 9980
#     external = 9980
#   }
#   volumes { 
#     host_path = "${var.volume_path}/filestash/data"
#     container_path = "/app/data/state/"
#   }
#   user = "root"

#   command = [
#     "/bin/bash",
#     "-c",
#     <<EOT
#       curl -o /usr/share/coolwsd/browser/dist/branding-desktop.css https://gist.githubusercontent.com/mickael-kerjean/bc1f57cd312cf04731d30185cc4e7ba2/raw/d706dcdf23c21441e5af289d871b33defc2770ea/destop.css
#       /bin/su -s /bin/bash -c '/start-collabora-online.sh' cool
#     EOT
#   ]
#   # command = ["-db" "/data/store.db"]
# }

resource "docker_container" "filestash" {
  name  = "filestash"
  image = docker_image.filestash.image_id

  restart = "unless-stopped"
  ports {
    internal = 8334
    external = 8334
  }
  # user = "root"
  
  env = [
    "APPLICATION_URL=",
    "CANARY=true",
    "OFFICE_URL=http://localhost:9980",
    "OFFICE_FILESTASH_URL=http://localhost:8334",
    "OFFICE_REWRITE_URL=http://127.0.0.1:9980"
  ]

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes { 
    # host_path = "${var.volume_path}/filestash/data"
    host_path = "/mnt/windows/Users/kai10/Desktop/filestash/data"
    container_path = "/app/data/state/"
  }

  # command = ["-db" "/data/store.db"]
}

resource "docker_container" "sftp-server" {
  name  = "sftp-server"
  image = docker_image.sftp-server.image_id

  restart = "unless-stopped"

  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes { 
    host_path = "${var.volume_path}/filestash/sftp_config"
    container_path = "/etc/sftp"
    read_only = true
  }

}
