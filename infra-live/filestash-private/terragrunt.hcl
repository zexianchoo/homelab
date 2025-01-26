terraform {
  source = "../../infra-modules/filestash-private" 
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
  # pico_pass = local.env_vars.PICOSHARE_PASS
  # projectsend_db_password = local.env_vars.PROJECTSEND_MYSQL_PASS
  # projectsend_db_root_password = local.env_vars.PROJECTSEND_MYSQL_ROOT_PASS
  # projectsend_db_database = local.env_vars.PROJECTSEND_MYSQL_DATABASE
  # projectsend_db_user = local.env_vars.PROJECTSEND_MYSQL_USER
}
