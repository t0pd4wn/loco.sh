#!/bin/bash
#-------------------------------------------------------------------------------
# utils.sh | utils functions
#-------------------------------------------------------------------------------

#######################################
# Check if the current user is root
# GLOBALS:
#   LOCO_DIST
# Output:
#   ./src/temp/conf_is_start
#######################################
utils::check_if_start(){
  # check if first start (stores $USER without sudo)
  if [ -f "./src/temp/conf_is_start" ]; then
    # program is started
    utils::remove ./src/temp/conf_is_start
  else
    msg::start
  fi
}

#######################################
# Check if the current user is root and source CURRENT_USER
# Arguments:
#   IS_ROOT
#   CURRENT_USER
# Output:
#   ./src/temp/conf_is_start
#   ./src/temp/conf_CURRENT_USER
#######################################
utils::check_if_root(){
  if [[ "${ROOT_YES}" == false ]]; then
    if [[ "${IS_ROOT}" -ne 0 ]]; then
      msg::print "................................................................"
      msg::print "..............You need to run this script as " "sudo" "..............."
      msg::print "................................................................"
      # remove then stores current user name in a file
      # if ! rm ./src/temp/conf_CURRENT_USER; then
      #     echo "Unable to rm ./src/temp/conf_CURRENT_USER" >&2
      # fi
      echo "CURRENT_USER=""${CURRENT_USER}" > ./src/temp/conf_CURRENT_USER
      sudo -k 
      # once root write start flag
      echo "local is_start=true" > ./src/temp/conf_is_start
      [[ "$UID" -eq 0 ]] || exec sudo bash "$0" "${@-}"
    else
      utils::source ./src/temp/conf_CURRENT_USER
    fi
  fi
}

#######################################
# Check $OSTYPE and defines current OS
# GLOBALS:
#   LOCO_OSTYPE
#######################################
utils::check_operating_system(){
  msg::debug "$OSTYPE"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    #echo "Linux"
    LOCO_OSTYPE="ubuntu"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    #echo "MacOs"
    LOCO_OSTYPE="macos" 
  else 
    echo "Operating System not supported."
    exit 1
  fi 
}

#######################################
# Removes temp files.
#######################################
utils::clean_temp(){
  utils::remove "./src/temp/*"
}

#######################################
# Copy from to
# Arguments:
#   $1 # from
#   $2 # to
#######################################
utils::cp(){
  local from="${1-}"
  local to="${2-}"
  if ! cmd::run_as_user "cp -r "${from}" "${to}""; then
    echo "Unable to copy ${from} in ${to}" >&2
  fi
}

#######################################
# Echo a message
# Arguments:
#   $1 # from
#   $2 # to
#######################################
utils::echo(){
  local message="${@-}"
  if ! cmd::run_as_user "echo -e '"${message}"'"; then
    echo "Unable to echo -e ${message}" >&2
  fi
}

#######################################
# Set GLOBALS
#######################################
utils::GLOBALS_set(){
  # readonly ?
  IS_ROOT=$(id -u)
  # used in cli
  declare -ga CLI_OPT_PARAMETERS
  declare -ga CLI_OPT_DESCRIPTIONS
  declare -ga HELP_TEXT
  # used in messages
  declare -ga MSG_ARRAY
  MSG_INDEX=0
  # used in prompts
  declare -g USER_ANSWER
  # used in package manage
  PACKAGE_MANAGER_TEST_CMD=""
  PACKAGE_TEST_CMD=""
  PACKAGE_ACTION_CMD=""
  # used in wget installation
  # LOCO_DIST=""
  # emojis
  readonly EMOJI_LOGO="\U1f335"
  readonly EMOJI_STOP="\U1F6A8"
  readonly EMOJI_YES="\U1F44D"
  readonly EMOJI_NO="\U1F44E"
}

#######################################
# Lock GLOBALS
#######################################
utils::GLOBALS_lock(){
  # can be selected later
  # readonly CURRENT_USER
  # can be defined at runtime
  # readonly ACTION
  # readonly PROFILE
  readonly PROFILES_DIR
  readonly INSTANCES_DIR
  readonly CONFIG_PATH
  readonly WATERMARK
  readonly DETACHED
  readonly LOCO_YES
  readonly VERBOSE
  readonly VERSION
}

#######################################
# List files and folders
# Arguments:
#   $1 // a normative array name
#   $2 // a path
#######################################
utils::list(){
  local -n list_name="${1-}"
  local list_path="${2-}"
  local element_name
  # prevail empty folders
  shopt -s nullglob
  # iterate over aguments paths
  for element_path in "${list_path}"/.??* "${list_path}"/*; do
    msg::debug "${element_path}"
    element_name=${element_path##*/}
    msg::debug "${element_name}"
    list_name+=("${element_name}")
  done
  shopt -u nullglob
}

#######################################
# Make a directory
# Arguments:
#   $1 // a path
#######################################
utils::mkdir(){
  local path="${@-}"
  if ! cmd::run_as_user "mkdir -p ""${path}"; then
    echo "Unable to create "${path}"" >&2
  fi
}

#######################################
# Remove file(s) or folder(s).
# Arguments:
#   $1 // a path
#######################################
utils::remove(){
  local path="${@-}"
  # unset eu due to rm exits
  set +eu
  # try two different expansions 
  if ! sudo rm -R ${path}; then
    if ! sudo rm -R "$path"; then
      msg::debug "Unable to remove $path"
      echo "Unable to remove $path" >&2
      else 
      msg::debug "REMOVED"
    fi
  fi
  # re-set eu
  set -eu
}

#######################################
# Set system clock (needed in  virtual hosts)
#######################################
utils::set_clock(){
  if ! sudo hwclock --hctosys; then
    echo "Unable to set clock" >&2
  fi
}

#######################################
# Source a file
# Arguments:
#   $1 // a path
#   $2 // options
#######################################
utils::source(){
  local path="${1-}"
  local arg="${2-}"
  if ! source "${path}" $arg; then
    echo "Unable to source $path" >&2
  fi
}

#######################################
# Print a timestamp.
#######################################
utils::timestamp(){
  # print current time
  date +"%Y-%m-%d_%H-%M-%S"
}

#######################################
# Download and source the parse_yaml script.
#######################################
utils::yaml_source_parser(){
  # get parse_yaml "https://github.com/mrbaseman/parse_yaml"
  local script_url="https://raw.githubusercontent.com/mrbaseman/parse_yaml/master/src/parse_yaml.sh"
  utils::get_url "./src/temp/" "${script_url}"

  # source file
  utils::source ./src/temp/parse_yaml.sh

  # commented out because /src/temp/ is full rm'd at each start
  # if true, keep a copy locally
  # local cache_flag=false
  # if [[ "${cache_flag}" == false ]]; then
  #   utils::remove "./src/temp/parse_yaml.sh"
  # fi
}

#######################################
# Build and source the profiles yaml.
# Globals:
#   PROFILE
#   PROFILES_DIR
# Output:
#   ./src/temp/"${PROFILE}"_yaml_variables.sh
#######################################
utils::yaml_read(){
  local path="${1-}"
  local output="${2-}"

  # check if file exist
  if [[ ! -f "${path}" ]]; then
    msg::print "${EMOJI_STOP} No " "YAML file" " found" >&2
  else
    # parse the $PROFILE yaml
    if ! parse_yaml "${path}" "" > "${output}"; then
      echo "Unable to parse YAML" >&2
    fi
    # clean the result file
    sed -i 's/_=" /_="/g' "${output}"
    sed -i 's/_="/="/g' "${output}"
    if (( $? != 0 )); then
      echo "Unable to sed ${output}" >&2
    fi
    # source the result file
    utils::source "${output}"
  fi
}

#######################################
# Wget a file in a folder. (deprecated in favor to utils::get_url)
# Arguments:
#   $1 // a path
#   $2 // an url
#######################################
utils::wget(){
  local path="${1-}"
  local url="${2-}"
  if ! cmd::run_as_user "wget -nc -q -P " "${path}" "${url}"; then
    msg::debug "Unable to wget ${url}"
    echo "Unable to wget ${url}" >&2
  fi
}

#######################################
# Get a file from an URL into a folder.
# Arguments:
#   $1 // a folder path
#   $2 // an url
#######################################
utils::get_url(){
  local path="${1-}"
  local url="${2-}"
  local curl_options="--create-dirs -C - -LOs --output-dir"
  if eval 'command -v wget' > /dev/null 2>&1; then
    msg::debug "wget is used"
    cmd::run_as_user "wget -nc -q -P " "${path}" "${url}"
  else
    msg::debug "curl is used"
    cmd::run_as_user "curl ${curl_options} " "${path}" "${url}"
  fi
}