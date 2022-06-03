#!/bin/bash
#-------------------------------------------------------------------------------
# loco_custom_functions.sh | loco.sh custom functions
#-------------------------------------------------------------------------------

#######################################
# Prepare custom functions execution
# GLOBALS:
#   ACTION
#   LOCO_OSTYPE
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # "entry" or "exit"
#######################################
loco::custom_action(){
  local custom_function_path="./"${PROFILES_DIR}"/"${PROFILE}"/custom.sh"
  if [[ -f "${custom_function_path}" ]]; then
    local step="${1-}"
    local generic_function="${ACTION}_${step}"
    local os_specific_function="${ACTION}_${LOCO_OSTYPE}_${step}"
    loco::custom_function "${generic_function}"
    loco::custom_function "${os_specific_function}"
  else
    msg::debug "No custom.sh file found." 
  fi
}

#######################################
# Execute custom functions
# Arguments:
#   $1 # a function name
#######################################
loco::custom_function(){
  local custom_function=${1-}
  if [[ $(type -t "${custom_function}") == function ]]; then
    "${custom_function}"
  else
    msg::debug "No "${custom_function}" function found."
  fi
}

#######################################
# Source and execute entry custom functions
# GLOBALS:
#   PROFILE
#######################################
loco::custom_entry(){
  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " custom functions."
  loco::custom_source
  loco::custom_action "entry"
}

#######################################
# Execute custom exit functions
#######################################
loco::custom_exit(){
  loco::custom_action "exit"
}

#######################################
# Execute custom last functions
#######################################
loco::custom_last(){
  loco::custom_action "last"
}

#######################################
# Source the custom functions file.
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
#######################################
loco::custom_source(){
  utils::source ./"${PROFILES_DIR}"/"${PROFILE}"/custom.sh
  if [ $? -ne 0 ]; then
    msg::print "No custom.sh file found."
  fi
}