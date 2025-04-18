terraform {
  source = "../../infra-modules/planka" 
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
  planka_secretkey = local.env_vars.PLANKA_SECRETKEY
  planka_email = local.env_vars.PLANKA_EMAIL
  planka_pass = local.env_vars.PLANKA_PASS
  planka_name = local.env_vars.PLANKA_NAME
  planka_username = local.env_vars.PLANKA_USERNAME
}
