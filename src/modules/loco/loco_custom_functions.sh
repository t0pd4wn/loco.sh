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
    if [[ "${ACTION}" == "update" ]]; then
      #if action is "update", then use the "install" custom functions
      local generic_function="install_${step}"
    else
      # else call dynamically
      local generic_function="${ACTION}_${step}"
    fi
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
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "entry"
  done

  PROFILE="${profile_backup}"
}

#######################################
# Execute custom exit functions
#######################################
loco::custom_exit(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "exit"
  done

  PROFILE="${profile_backup}"
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
    msg::print "Can not source custom.sh file."
  fi
}