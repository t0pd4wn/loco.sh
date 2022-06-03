#!/bin/bash
#-------------------------------------------------------------------------------
# loco_startup.sh | loco.sh startup functions
#-------------------------------------------------------------------------------

#######################################
# Call the startup functions.
# Globals:
#   CONFIG_PATH
#   IS_ROOT
#   ACTION
# Arguments:
#   $@ just in case
#######################################
loco::startup(){
  # remove temp files
  utils::clean_temp

  # set system clock
  utils::set_clock

  # externally source the yaml parser 
  # https://github.com/mrbaseman/parse_yaml
  utils::yaml_source_parser

  # print the warning message
  msg::warning

  # build and source the actions prompt file, if there is no option set
  loco::prompt_action
}

#######################################
# for macOS check if brew is installed or install it
# GLOBALS:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::mac_has_brew(){
  # install homebrew if on macos
  if [[ "${LOCO_OSTYPE}" == "macos" ]];  then
    echo "macos"
      PACKAGE="brew"
      PACKAGE_ACTION_CMD='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      loco::meta_package "${PACKAGE}" "${PACKAGE_ACTION_CMD}"
  fi
}

#######################################
# for macOS check if bash 4.* is installed or install it
# GLOBALS:
#   ACTION
#   PACKAGE
#   PACKAGE_MANAGER
#######################################
loco::mac_has_bash(){
  # install homebrew if on macos
  if [[ $(bash -c 'echo ${BASH_VERSINFO[0]}') -eq 3 ]];  then
    echo "bash 3"
      PACKAGE_MANAGER="brew"
      PACKAGE_ACTION="install"
      PACKAGE="bash"
      loco::meta_action
  fi
}