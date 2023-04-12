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
  utils::mkdir "./${PROFILES_DIR}/.Multi/dotfiles"
  utils::mkdir "./${PROFILES_DIR}/.Multi/assets"

  # iterate over profiles directories
  for sub_profile in "${profiles[@]}"; do

    echo $sub_profile
  done
  exit
}

#######################################
# Copy profiles assets
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
#######################################
# loco::multi_assets(){}

#######################################
# Merge profiles dotfiles
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
#######################################
# loco::multi_dotfiles(){}

#######################################
# Merge profiles yaml
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
#######################################
# loco::multi_yaml(){}