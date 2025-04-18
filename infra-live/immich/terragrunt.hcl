terraform {
  source = "../../infra-modules/immich" 
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
  project_name = local.global_vars.project_name
}

inputs = {
  network_name = dependency.docker-network.outputs.network_name
  domain_name = local.global_vars.domain_name
  volume_path = local.global_vars.volume_path
  module_path = local.global_vars.module_path
  immich_db_pass = local.env_vars.IMMICH_DB_PASS
  immich_db_name = local.env_vars.IMMICH_DB_NAME
  immich_db_user = local.env_vars.IMMICH_DB_USER
  immich_db_host = local.env_vars.IMMICH_DB_HOST
  immich_mnt_pt = local.env_vars.IMMICH_PHOTO_MNT_POINT
}
