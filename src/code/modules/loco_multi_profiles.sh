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
    loco::multi_assets "${profile}"
    loco::multi_dotfiles "${profile}"
    loco::multi_yaml "${profile}"
    loco::multi_custom_functions "${profile}"
  done

  PROFILE=".Multi"
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
 loco::multi_dotfiles(){
  local profile="${1-}"
  local from_path=./${PROFILES_DIR}/"${profile}"/dotfiles
  local dest_path=./${PROFILES_DIR}/.Multi/dotfiles

  if [[ $(ls -A ${dest_path}) ]]; then
  # if destination folder is not empty
    loco::dotfiles_merge "${from_path}" "${dest_path}"
  else
  # if empty, copy files in destination folder
    utils::cp "${from_path}/." "${dest_path}/"
  fi
 }

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
#   $1 # from profile
#######################################
loco::multi_custom_functions(){
  local profile="${1-}"
  local from_custom=./${PROFILES_DIR}/"${profile}"/custom.sh
  local dest_custom=./${PROFILES_DIR}/.Multi/custom.sh

  if [[ -f "${dest_custom}" ]]; then
  # if destination file exists, merge files
    loco::custom_merge "${from_custom}" "${dest_custom}"
  else
  # if not, copy file as destination file
    utils::cp "${from_custom}" "${dest_custom}"
  fi
}