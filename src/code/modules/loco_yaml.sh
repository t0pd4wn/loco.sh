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

#######################################
# Merge two yaml files together
# Arguments:
#   $1 # a yaml to be merged from (A)
#   $2 # a yaml to be merged with (B)
#   $3 # a temp file to keep the result
#######################################
loco::yaml_merge(){
  local yaml_from="${1-}"
  local yaml_to="${2-}"
  local result_yaml="${3-}"
  local from_list
  local to_list
  local style_part
  local packages_part

  # grab the yaml values from the two files
  from_style_list=$(yaml::get "${yaml_from}" ".style")
  to_style_list=$(yaml::get "${yaml_to}" ".style")
  from_packages_list=$(yaml::get "${yaml_from}" ".packages")
  to_packages_list=$(yaml::get "${yaml_to}" ".packages")

  # add the yaml values temporarily in the destination file
  yaml::add "${yaml_to}" ".styleA" "${from_style_list}" "raw"
  yaml::add "${yaml_to}" ".styleB" "${to_style_list}" "raw"
  yaml::add "${yaml_to}" ".packagesA" "${from_packages_list}" "raw"
  yaml::add "${yaml_to}" ".packagesB" "${to_packages_list}" "raw"

  # merge values together and keep them in variables
  style_part=$(yaml::merge "${yaml_to}" ".styleA" ".styleB" "classic")
  packages_part=$(yaml::merge "${yaml_to}" ".packagesA" ".packagesB" "array")

  # remove destination file
  utils::remove ${yaml_to}

  # write merged values in new destination file
  utils::echo "style:" > ${yaml_to}
  utils::echo "packages:" >> ${yaml_to}
  yaml::add "${yaml_to}" ".style" "${style_part}" "raw"
  yaml::add "${yaml_to}" ".packages" "${packages_part}" "raw"
}