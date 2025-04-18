terraform {
  source = "../../infra-modules/firefly" 
}

dependency "docker-network" {
  config_path = "../docker-network"
   mock_outputs = {
   }
   mock_outputs_merge_strategy_with_state = "shallow"
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
  project_name = local.global_vars.project_name
}

inputs = {
  network_name = dependency.docker-network.outputs.network_name
  domain_name = local.global_vars.domain_name
  volume_path = local.global_vars.volume_path
  module_path = local.global_vars.module_path

  # firefly_random_root_password = local.env_vars.FIREFLY_IMPORTER_MYSQL_RANDOM_ROOT_PASSWORD
  # firefly_mysql_user = local.env_vars.FIREFLY_IMPORTER_MYSQL_USER
  # firefly_mysql_password = local.env_vars.FIREFLY_IMPORTER_MYSQL_PASSWORD
  # firefly_mysql_database = local.env_vars.FIREFLY_IMPORTER_MYSQL_DATABASE
}
