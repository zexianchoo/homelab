# terraform {
#   source = "../../infra-modules/nginx-proxy-manager" 
# }

# dependency "docker-network" {
#   config_path = "../docker-network"
#    mock_outputs = {
#     network_name = "homelab"
#    }
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
#   project_name = local.global_vars.project_name
# }

# inputs = {
#   network_name = dependency.docker-network.outputs.network_name
#   domain_name = local.global_vars.domain_name
#   volume_path = local.global_vars.volume_path
# }
