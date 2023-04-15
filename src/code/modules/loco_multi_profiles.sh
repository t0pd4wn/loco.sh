#!/bin/bash
#-------------------------------------------------------------------------------
# loco_merge_profiles.sh | loco.sh merge profiles functions
#-------------------------------------------------------------------------------

#######################################
# Prepare .Multi folder for receiving other profiles
# GLOBALS:
#   PROFILES_DIR
# Arguments:
#   $1 # an array of profiles
#######################################
loco::multi_prepare(){
  declare -a profiles
  profiles=("${@}")

  # create a .Multi folder
  utils::mkdir "./${PROFILES_DIR}/.Multi"
  utils::mkdir "./${PROFILES_DIR}/.Multi/assets"
  utils::mkdir "./${PROFILES_DIR}/.Multi/dotfiles"

  # iterate over profiles directories
  for profile in "${profiles[@]}"; do
    echo "before installing ${profile}"
    loco::multi_assets "${profile}"
    # loco::multi_dotfiles "${profile}"
    loco::multi_yaml "${profile}"
    echo "after installing ${profile}"
  done
  _exit
}

#######################################
# Copy profiles assets
# GLOBALS:
# Arguments:
#   $1 # a profile name
#######################################
loco::multi_assets(){
  local profile="${1-}"
  local from="./${PROFILES_DIR}/${profile}/assets"
  local to="./${PROFILES_DIR}/.Multi/assets"
  
  # if $profile/assets/ exists copy content in .Multi/assets/
  if [[ -d "${from}" ]]; then
    utils::cp "${from}/*" "${to}"
  fi
}

#######################################
# Merge profiles dotfiles
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
#######################################
# loco::multi_dotfiles(){

# }

#######################################
# Merge profiles yaml
# GLOBALS:
# Arguments:
#   $1 # from profile
#######################################
 loco::multi_yaml(){
  local profile="${1-}"
  local from_yaml=./${PROFILES_DIR}/"${profile}"/profile.yaml
  local dest_yaml=./${PROFILES_DIR}/.Multi/profile.yaml
  local temp_yaml=./${PROFILES_DIR}/.Multi/temp.yaml

  if [[ -f "${dest_yaml}" ]]; then
  # if destination file exists, merge files
    loco::yaml_merge "${from_yaml}" "${dest_yaml}" "${temp_yaml}"
  else
  # if not, copy file as destination file
    utils::cp "${from_yaml}" "${dest_yaml}"
  fi
 }

 #######################################
# Merge profiles custom functions files
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
#######################################
# loco::multi_custom_functions(){

# }