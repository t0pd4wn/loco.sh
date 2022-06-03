#!/bin/bash
#-------------------------------------------------------------------------------
# loco_yaml.sh | loco.sh yaml functions
#-------------------------------------------------------------------------------

#######################################
# Build and source the profiles yaml.
# Globals:
#   PROFILE
#   PROFILES_DIR
#   YAML_PATH
# Output:
#   ./src/temp/"${PROFILE}"_yaml_variables.sh
#######################################
loco::yaml_profile(){
  YAML_PATH="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
}