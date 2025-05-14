terraform {
  source = "../../infra-modules/obsidian" 
}

dependency "docker-network" {
  config_path = "../docker-network"
   mock_outputs = {
   }
   mock_outputs_merge_strategy_with_state = "shallow"
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  project_name = local.global_vars.project_name
}

inputs = {
  network_name = dependency.docker-network.outputs.network_name
  domain_name = local.global_vars.domain_name
  volume_path = local.global_vars.volume_path
  OBSIDIAN_COUCHDB_USER = local.env_vars.OBSIDIAN_COUCHDB_USER
  OBSIDIAN_COUCHDB_PASS = local.env_vars.OBSIDIAN_COUCHDB_PASS
}
