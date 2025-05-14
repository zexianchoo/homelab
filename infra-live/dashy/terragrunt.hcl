terraform {
  source = "../../infra-modules/dashy" 
}

dependency "docker-network" {
  config_path = "../docker-network"
   mock_outputs = {
    network_name = "homelab"
  }
   mock_outputs_merge_strategy_with_state = "shallow"
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  env_vars = yamldecode(file(find_in_parent_folders("env-vars.yml")))
  secrets = yamldecode(sops_decrypt_file(find_in_parent_folders("encrypted_secrets.yml")))
  project_name = local.global_vars.project_name
}

inputs = {
  network_name = dependency.docker-network.outputs.network_name
  domain_name = local.global_vars.domain_name
  volume_path = local.global_vars.volume_path
  module_path = local.global_vars.module_path
  dockerhub_user = local.secrets.dockerhub_user
  dockerhub_pass = local.secrets.dockerhub_pass
}
