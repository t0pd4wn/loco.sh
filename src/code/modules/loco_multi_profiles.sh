#!/bin/bash
#-------------------------------------------------------------------------------
# loco_merge_profiles.sh | loco.sh merge profiles functions
#-------------------------------------------------------------------------------

########################################
# Prepare .Multi folder for receiving other profiles
# GLOBALS:
#   PROFILES_DIR
# Arguments:
#   $1 # an array of profiles
########################################
loco::multi_prepare(){
  declare -a profiles
  profiles=("${@}")
  PROFILE=".Multi-$(utils::timestamp)"

  # create a .Multi folder
  _mkdir "./${PROFILES_DIR}/${PROFILE}"
  _mkdir "./${PROFILES_DIR}/${PROFILE}/assets"
  _mkdir "./${PROFILES_DIR}/${PROFILE}/dotfiles"

  # iterate over profiles directories
  for profile in "${profiles[@]}"; do
    loco::multi_assets "${profile}"
    loco::multi_dotfiles "${profile}"
    loco::multi_yaml "${profile}"
    loco::multi_custom_functions "${profile}"
  done
}

########################################
# Copy profiles assets
# GLOBALS:
# Arguments:
#   $1 # a profile name
########################################
loco::multi_assets(){
  local profile_arg="${1-}"
  local from="./${PROFILES_DIR}/${profile_arg}/assets"
  local to="./${PROFILES_DIR}/${PROFILE}/assets"
  
  # if $profile/assets/ exists copy content in .Multi/assets/
  if [[ -d "${from}" ]]; then
    _cp "${from}/*" "${to}"
  fi
}

########################################
# Merge profiles dotfiles
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
########################################
 loco::multi_dotfiles(){
  local profile_arg="${1-}"
  local from_path=./${PROFILES_DIR}/"${profile_arg}"/dotfiles
  local dest_path=./${PROFILES_DIR}/${PROFILE}/dotfiles

  if [[ $(ls -A ${dest_path}) ]]; then
  # if destination folder is not empty
    loco::dotfiles_merge "${from_path}" "${dest_path}"
  else
  # if empty, copy files in destination folder
    _cp "${from_path}/." "${dest_path}/"
  fi
 }

########################################
# Merge profiles yaml
# GLOBALS:
# Arguments:
#   $1 # from profile
########################################
 loco::multi_yaml(){
  local profile_arg="${1-}"
  local from_yaml=./${PROFILES_DIR}/"${profile_arg}"/profile.yaml
  local dest_yaml=./${PROFILES_DIR}/${PROFILE}/profile.yaml

  if [[ -f "${dest_yaml}" ]]; then
  # if destination file exists, merge files
    loco::yaml_merge "${from_yaml}" "${dest_yaml}"
  else
  # if not, copy file as destination file
    _cp "${from_yaml}" "${dest_yaml}"
  fi
 }

 ########################################
# Merge profiles custom functions files
# GLOBALS:
# Arguments:
#   $1 # from profile
########################################
loco::multi_custom_functions(){
  local profile_arg="${1-}"
  local from_custom=./${PROFILES_DIR}/"${profile_arg}"/custom.sh
  local dest_custom=./${PROFILES_DIR}/${PROFILE}/custom.sh

  if [[ -f "${dest_custom}" ]]; then
  # if destination file exists, merge files
    loco::custom_merge "${from_custom}" "${dest_custom}"
  else
  # if not, copy file as destination file
    _cp "${from_custom}" "${dest_custom}"
  fi
}