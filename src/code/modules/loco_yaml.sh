#!/bin/bash
#-------------------------------------------------------------------------------
# loco_yaml.sh | loco.sh yaml functions
#-------------------------------------------------------------------------------

########################################
# Assign yaml paths to globals.
# Globals:
#   PROFILE
#   OS_PREFIX
#   CURRENT_USER
#   PROFILES_DIR
#   PROFILE_YAML
#   INSTANCE_YAML
########################################
loco::yaml_init(){
  PROFILE_YAML="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
  INSTANCE_YAML=/"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml
  TEMP_YAML="src/temp/yaml.local"
}

########################################
# Merge two yaml files together
# Arguments:
#   $1 # a yaml to be merged from (A)
#   $2 # a yaml to be merged with (B)
########################################
loco::yaml_merge(){
  local yaml_from="${1-}"
  local yaml_to="${2-}"

  local from_style_list
  local to_style_list
  local from_packages_list
  local to_packages_list  
  local from_dotfiles_list
  local to_dotfiles_list  
  local from_functions_list
  local to_functions_list

  local style_part
  local packages_part
  local dotfiles_part  
  local functions_part

  # grab the yaml values from the two files
  from_style_list=$(yaml::get "${yaml_from}" ".style")
  to_style_list=$(yaml::get "${yaml_to}" ".style")
  from_packages_list=$(yaml::get "${yaml_from}" ".packages")
  to_packages_list=$(yaml::get "${yaml_to}" ".packages")
  from_dotfiles_list=$(yaml::get "${yaml_from}" ".dotfiles")
  to_dotfiles_list=$(yaml::get "${yaml_to}" ".dotfiles")  
  from_functions_list=$(yaml::get "${yaml_from}" ".custom_functions")
  to_functions_list=$(yaml::get "${yaml_to}" ".custom_functions")

  # add the yaml values temporarily in the destination file
  yaml::add "${yaml_to}" ".styleA" "${from_style_list}" "raw"
  yaml::add "${yaml_to}" ".styleB" "${to_style_list}" "raw"
  yaml::add "${yaml_to}" ".packagesA" "${from_packages_list}" "raw"
  yaml::add "${yaml_to}" ".packagesB" "${to_packages_list}" "raw"  
  yaml::add "${yaml_to}" ".dotfilesA" "${from_dotfiles_list}" "raw"
  yaml::add "${yaml_to}" ".dotfilesB" "${to_dotfiles_list}" "raw"  
  yaml::add "${yaml_to}" ".funsA" "${from_functions_list}" "raw"
  yaml::add "${yaml_to}" ".funsB" "${to_functions_list}" "raw"

  # merge values together and keep them in variables
  # check if one or the other value is empty
  if [[ -z "${from_style_list}" || -z "${to_style_list}" ]]; then
    # if yes keep only non-empty variable
    style_part="${from_style_list:-$to_style_list}"
  else
    # if not merge yaml variables
    style_part=$(yaml::merge "${yaml_to}" ".styleA" ".styleB" "classic")
  fi

  # same for packages
  if [[ -z "${from_packages_list}" || -z "${to_packages_list}" ]]; then
    packages_part="${from_packages_list:-$to_packages_list}"
  else
    packages_part=$(yaml::merge "${yaml_to}" ".packagesA" ".packagesB" "array-merge")
  fi

  # same for dotfiles
  if [[ -z "${from_dotfiles_list}" || -z "${to_dotfiles_list}" ]]; then
    dotfiles_part="${from_dotfiles_list:-$to_dotfiles_list}"
  else
    dotfiles_part=$(yaml::merge "${yaml_to}" ".dotfilesA" ".dotfilesB" "array-merge")
  fi

  # same for custom functions
  if [[ -z "${from_functions_list}" || -z "${to_functions_list}" ]]; then
    functions_part="${from_functions_list:-$to_functions_list}"
  else
    # additional condition if custom functions are identical
    if [[ "${from_functions_list}" == "${to_functions_list}"  ]]; then
      functions_part="${from_functions_list}"
    else
      functions_part=$(yaml::merge "${yaml_to}" ".funsA" ".funsB" "array-append")
    fi
  fi

  # style_part=$(yaml::merge "${yaml_to}" ".styleA" ".styleB" "classic")
  # packages_part=$(yaml::merge "${yaml_to}" ".packagesA" ".packagesB" "array-merge")
  # dotfiles_part=$(yaml::merge "${yaml_to}" ".dotfilesA" ".dotfilesB" "array-merge")  

  # remove destination file
  utils::remove ${yaml_to}

  # write merged values in new destination file
  # create selectors
  _echo "style:" > ${yaml_to}
  _echo "packages:" >> ${yaml_to}
  _echo "dotfiles:" >> ${yaml_to}  
  _echo "custom_functions:" >> ${yaml_to}
  
  # write yaml values to selectorsq 
  yaml::add "${yaml_to}" ".style" "${style_part}" "raw"
  yaml::add "${yaml_to}" ".packages" "${packages_part}" "raw"
  yaml::add "${yaml_to}" ".dotfiles" "${dotfiles_part}" "raw"  
  yaml::add "${yaml_to}" ".custom_functions" "${functions_part}" "raw"
}