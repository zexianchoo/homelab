output "glance_image_id" {
  value = docker_image.glance.id
  description = "Name of the glance Docker container"
}

output "glance-container_id" {
  value = docker_container.glance.id
  description = "Name of the glance Docker container"
}
