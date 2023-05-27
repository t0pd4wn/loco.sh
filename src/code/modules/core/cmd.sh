#!/bin/bash
#-------------------------------------------------------------------------------
# cmd.sh | cmd.sh functions
#-------------------------------------------------------------------------------

########################################
# Register commands to finish.sh
# Arguments:
#   $1 # a command
# Output:
#   src/temp/finish.sh
########################################
cmd::record(){
  local command="${@-}"
  local script_path="./src/temp/finish.sh"

  if [[ ! -f "${script_path}" ]]; then
    _echo "${command}" > "${script_path}"
    chmod +x "${script_path}"
  else 
    _echo "${command}" >> "${script_path}"
  fi
}

########################################
# Run a command as current user
# GLOBALS:
#   CURRENT_USER
# Arguments:
#   $1 # a command
########################################
cmd::run_as_user(){
  local command="${@-}"

  if ! su "${CURRENT_USER}" -c "${command}"; then
    msg::debug "Can not su ${command}"
    echo "Can not su ${command}" >&2
  fi
}

########################################
# Run a command
# GLOBALS:
#   CURRENT_USER
# Arguments:
#   $1 # a command
########################################
cmd::execute(){
  local command="${@-}"

  # create an array on space delimeter
  IFS=' ' read -r -a command_array <<< "${command}"
  # expand command array to execute it
  "${command_array[@]}"
}