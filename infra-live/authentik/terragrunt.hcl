# terraform {
#   source = "../../infra-modules/authentik" 
# }

# dependency "docker-network" {
#   config_path = "../docker-network"
#    mock_outputs = {}
#    mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "glance" {
#   config_path = "../glance"
#    mock_outputs = {}
#    mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "homer-public" {
#   config_path = "../homer-public"
#    mock_outputs = {}
#    mock_outputs_merge_strategy_with_state = "shallow"
# }

# locals {
#   global_vars = yamldecode(file(find_in_parent_folders("global-vars.yml")))
#   env_vars = yamldecode(file(find_in_parent_folders("env-vars.yml")))
#   project_name = local.global_vars.project_name
# }

# inputs = {
#   network_name = dependency.docker-network.outputs.network_name
#   domain_name = local.global_vars.domain_name
#   pg_user           = local.env_vars.PG_USER
#   pg_pass           = local.env_vars.PG_PASS
#   pg_db             = local.env_vars.PG_DB
#   secret_key             = local.env_vars.SECRET_KEY
# }
