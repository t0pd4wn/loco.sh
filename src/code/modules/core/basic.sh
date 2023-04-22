
#######################################
# Cat
# Arguments:
#   $1 # command argument
#######################################
_cat(){
  local arg="${@-}"

  if ! cat "${arg}"; then
    _error "Unable to cat ${arg}"
  fi
}

#######################################
# Chmod a path
# Arguments:
#   $1 # command argument "666 -R"
#   $2 # /path/to/
#######################################
_chmod(){
  local arg="${1-}"
  local path="${2-}"

  if ! chmod "${arg}" ${path}; then
    _error "Unable to chmod ${path} with ${arg}"
  fi
}

#######################################
# Chown a path
# Arguments:
#   $1 # command argument "user_name"
#   $2 # /path/to/
#######################################
_chown(){
  local arg="${1-}"
  local path="${2-}"

  if ! chown "${arg}" ${path}; then
    _error "Unable to chown ${path} to ${arg}"
  fi
}

#######################################
# Copy from to
# Arguments:
#   $1 # from
#   $2 # to
#######################################
_cp(){
  local from="${1-}"
  local to="${2-}"

  if ! cmd::run_as_user "cp -RL "${from}" "${to}""; then
    _error "Unable to copy ${from} in ${to}"
  fi
}

#######################################
# Echo a message
# Arguments:
#   $1 # from
#   $2 # to
#######################################
_echo(){
  local message="${@-}"
  if ! echo -e "${message}"; then
    _error "Unable to echo -e ${message}"
  fi
}

#######################################
# Print an error message in STDERR
#######################################
_error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: ${@-}" >&2 ":: $*"
}

#######################################
# Print an error and exit
#######################################
_exit() {
  _error "${@-}"
  exit 1
}

#######################################
# Get the size of a file
# Arguments:
#   $1 # /path/to/a/file
#######################################
_file_size(){
  local file="${1-}"

  if ! stat -c%s "${file}"; then
    _error "Unable to stat ${file}"
  fi
}

#######################################
# Create a symbolic link
# Arguments:
#   $1 # from /path/from/file
#   $2 # to /path/to/
# 
#######################################
_link(){
  local from="${1-}"
  local to="${2-}"

  if ! utils::run_as_user "ln -s "${from}" "${to}""; then
    _error "Unable to link "${from}" "${to}""
  fi
}

#######################################
# Make a directory
# Arguments:
#   $1 # a path
#######################################
_mkdir(){
  local path="${@-}"

  # check if directory exists
  if [[ -d "${path}" ]]; then
    msg::debug "${path} already exists"
  else
    if ! cmd::run_as_user "mkdir -p ""${path}"; then
      _error "Unable to create ${path}"
    fi
  fi
}

#######################################
# Source a file
# Arguments:
#   $1 # a path
#   $2 # options
#######################################
_source(){
  local path="${1-}"
  local arg="${2-}"

  if ! source "${path}" $arg; then
    _error "Unable to source $path"
  fi
}