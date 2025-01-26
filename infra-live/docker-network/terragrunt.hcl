terraform {
  source = "../../infra-modules/docker-network" 
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  project_name = local.global_vars.project_name
}

inputs = {}
