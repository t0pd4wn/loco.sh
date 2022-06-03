#!/bin/bash
#-------------------------------------------------------------------------------
# cmd.sh | cmd.sh functions
#-------------------------------------------------------------------------------

#######################################
# Register commands to a file
# Arguments:
#   $1 // a command
#######################################
cmd::record(){
  local command="${@-}"
  local script_path="./src/temp/finish.sh"
  if [[ ! -f "${script_path}" ]]; then
    echo "${command}" > "${script_path}"
    chmod +x "${script_path}"
  else 
    echo "${command}" >> "${script_path}"
  fi
}

#######################################
# Display the cmd file message
# GLOBALS:
#   LOCO_DIST
# Arguments:
#   $1 // a command
#######################################
cmd::msg(){
  # check if current loco is remote installation
  local dist_path
  if [[ "${LOCO_DIST}" == true ]]; then
    dist_path="~/loco-dist/"
  fi
  # check if finish file is present
  local script_path="./src/temp/finish.sh"
  local prefix=${dist_path-"./"}
  msg::debug "${prefix}"
  if [[ -f "${script_path}" ]]; then
    msg::record 'type `'"${prefix}"'src/temp/finish.sh` to finish installation'
  fi
}

#######################################
# Runs a command as current user
# GLOBALS:
#   CURRENT_USER
# Arguments:
#   $1 // a command
#######################################
cmd::run_as_user(){
  local command="${@-}"
  if ! su "${CURRENT_USER}" -c "${command}"; then
    msg::debug "Can not su ${command}"
    echo "Can not su ${command}" >&2
  fi
}