#!/bin/bash
#-------------------------------------------------------------------------------
# loco_yaml.sh | loco.sh yaml functions
#-------------------------------------------------------------------------------

#######################################
# Assign yaml paths to globals.
# Globals:
#   PROFILE
#   OS_PREFIX
#   CURRENT_USER
#   PROFILES_DIR
#   PROFILE_YAML
#   INSTANCE_YAML
#######################################
loco::yaml_init(){
  PROFILE_YAML="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
  INSTANCE_YAML=/"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml
}