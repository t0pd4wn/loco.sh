#######################################
# Register commands to a file
# Globals:
# Arguments:
#   $1 // a command
#######################################
cmd::record(){
  local command="$@"
  local script_path="./src/temp/loco_finish.sh"
  if [[ ! -f "${script_path}" ]]; then
    echo "${command}" > "${script_path}"
    chmod +x "${script_path}"
  else 
    echo "${command}" >> "${script_path}"
  fi
}

#######################################
# Display the cmd file message
# Globals:
# Arguments:
#   $1 // a command
#######################################
cmd::play(){
  # check if current loco is remote installation
  local dist_path=""
  if [[ "${LOCO_DIST}" == true ]]; then
    dist_path="loco-dist/"
  fi
  local script_path="./src/temp/loco_finish.sh"
  if [[ -f "${script_path}" ]]; then
    msg::record 'type `./'"${dist_path}"'src/temp/loco_finish.sh` to finish installation'
  fi
}

#######################################
# Runs a command as current user
# Globals:
# Argumsnts:
#   $1 // a command
#######################################
cmd::run_as_user(){
  local command="${@-}"
  if ! su "${CURRENT_USER}" -c "${command}"; then
    msg::debug "Can not su ${command}"
    echo "Can not su ${command}" >&2
  fi
}