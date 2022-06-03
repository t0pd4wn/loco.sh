#!/bin/bash
#-------------------------------------------------------------------------------
# loco_yaml.sh | loco.sh yaml functions
#-------------------------------------------------------------------------------

#######################################
# Build and source the profiles yaml.
# Globals:
#   PROFILE
#   PROFILES_DIR
# Output:
#   ./src/temp/"${PROFILE}"_yaml_variables.sh
#######################################
loco::yaml_profile(){
  local yaml_path="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
  local destination_path="./src/temp/"${PROFILE}"_yaml_variables.sh"
  utils::yaml_read "${yaml_path}" "${destination_path}"
}