terraform {
  source = "../../infra-modules/caddy" 
}

dependency "docker-network" {
  config_path = "../docker-network"
   mock_outputs = {
   }
   mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "glance" {
  config_path = "../glance"
   mock_outputs = {}
   mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "firefly" {
  config_path = "../firefly"
   mock_outputs = {}
   mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "nextcloud" {
  config_path = "../nextcloud"
   mock_outputs = {}
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
  cloudflare_api_token = local.env_vars.CLOUDFLARE_API_TOKEN
}
