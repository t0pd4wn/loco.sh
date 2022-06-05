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
# Note : only methods from this file should be called.
#######################################
utils::check_operating_system(){

  echo "utils::check_operating_system"
  echo "${SHORT_OS_VERSION-}"

  if [[ -z "${SHORT_OS_VERSION-}" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      LOCO_OSTYPE="ubuntu"
      SHORT_OS_VERSION=$(lsb_release -r -s | cut -f1 -d'.')
      echo "${SHORT_OS_VERSION-}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      LOCO_OSTYPE="macos"
      # check if mac has brew
      utils::mac_has_brew
      # check if mac has bash 4+
      utils::mac_has_bash
      # get version information, then grep version line, cut full semver, cut main version "e.g 12"
      SHORT_OS_VERSION=$(sw_vers | grep "ProductVersion:" | cut -f2 | cut -f1 -d'.')
      echo "${SHORT_OS_VERSION-}"
    else 
      _exit "Operating System not supported."
    fi
  fi
}

#######################################
# Check if dependencies are met
# GLOBALS:
#   LOCO_OS_VERSION
#######################################
utils::check_dependencies(){
  if [[ $(command -v yq) ]]; then
    msg::say "yq is installed."
  else
    msg::say "Installing yq."
    if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
      snap install yq
    elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
      brew install yq
    fi
  fi
}

#######################################
# Removes temp files.
#######################################
utils::clean_temp(){
  utils::remove './src/temp/*'
}

#######################################
# Display a countdown
# Arguments:
#   $1 # message to be displayed
#   $2 # countdown duration
#######################################
utils::countdown(){
  local message="${1-}"
  local duration="${2-}"
  local seconds=$((1 * "${duration}"))
  while [ $seconds -gt 0 ]; do
     echo -ne "${message}" "$seconds\033[0K\r"
     sleep 1
     : $((seconds--))
  done
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
  if ! cmd::run_as_user "cp -RrL "${from}" "${to}""; then
    _error "Unable to copy ${from} in ${to}"
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
  if ! echo -e "${message}"; then
    _error "Unable to echo -e ${message}"
  fi
}

#######################################
# Escape special characters in a path
# Arguments:
#   $1 # a path with special characters
#######################################
utils::escape_string(){
  local string="${@-}"
  if ! printf %q "${string}"; then
    _error "Unable to escape ${string}"
  fi
}

#######################################
# Encode a path to URI
# Arguments:
#   $1 # a path
#######################################
utils::encode_URI(){
  local string="${@-}"
  if ! echo "${string}"| perl -MURI::file -e 'print URI::file->new(<STDIN>)'; then
    _error "Unable to decode ${string}"
  fi
}


#######################################
# Decode an URI to a path
# Arguments:
#   $1 # an URI
#######################################
utils::decode_URI(){
  local string="${@-}"
  if ! echo ''"${string}"'' | perl -pe 's/\%(\w\w)/chr hex $1/ge'; then
    _error "Unable to decode ${string}"
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
  # readonly THEME
  # readonly YAML_PATH
  # readonly IS_NEW_FONT
  # readonly SHORT_OS_VERSION
  readonly BACKGROUND_URL
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
# List files and folders within an array
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
    # substitute a / ?
    element_name=${element_path##*/}
    list_name+=("${element_name}")
  done
  shopt -u nullglob
}

#######################################
# For macOS check if brew is installed or install it
# GLOBALS:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
utils::mac_has_brew(){
  # if on macOS
  if [[ "${LOCO_OSTYPE}" == "macos" ]];  then

    # if brew is not installed
    if [[ $(command -v brew) == "" ]]; then
      echo -e "\U1f335 Homebrew needs to be installed."
      echo -e "\U1f335 Your password will be asked several times."
      PACKAGE_ACTION_CMD='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      loco::meta_action "${PACKAGE_ACTION_CMD}"
    else
      echo -e "\U1f335 Homebrew is installed."
    fi
  fi
}

#######################################
# for macOS check if bash 4.* is installed or install it
# GLOBALS:
#   ACTION
#   PACKAGE
#   PACKAGE_MANAGER
#######################################
utils::mac_has_bash(){
  # if bash version is equal to 3.x
  echo '${BASH_VERSINFO[0]}'
  echo ${BASH_VERSINFO[0]}
  if [[ ${BASH_VERSINFO[0]} -eq 3 ]];  then

    # if there is a binary in the brew/bash path
    if [[ -f /usr/local/bin/bash ]]; then
      echo -e "\U1f335 An other version of bash is installed."
      echo -e "\U1f335 Please, use the command below :"
      # todo : execute directly script under correct path
      # $(/usr/local/bin/bash ./loco)
      echo -e "/usr/local/bin/bash ./loco"
      # _exit
    # if not install brew/bash
    else
      echo -e "\U1f335 Bash 4+ will be installed."
      PACKAGE_ACTION_CMD='brew install bash'
      loco::meta_action
    fi
  else
    echo -e "\U1f335 Bash ${BASH_VERSINFO[0]} is installed."
  fi
}

#######################################
# Make a directory
# Arguments:
#   $1 // a path
#######################################
utils::mkdir(){
  local path="${@-}"
  if ! cmd::run_as_user "mkdir -p ""${path}"; then
    _error "Unable to create ${path}"
  fi
}

#######################################
# Remove a file
# Arguments:
#   $1 // a file path
#######################################
utils::remove_file(){
  local path="${@-}"

  # try three different expansions 
  if ! rm -R "${path}"; then
    if ! rm -R $path; then
      if ! rm -R "$path"; then
        msg::debug "Unable to remove $path"
        _error "Unable to remove $path"
      else 
        msg::debug "Managed to remove "$path" (3)"
      fi
    else
      msg::debug "Managed to remove $path (2)"
    fi
  else 
    msg::debug "Managed to remove "${path}" (1)"
  fi
}

#######################################
# Remove a path
# Arguments:
#   $1 // a path
#######################################
utils::remove(){
  local path="${@-}"
  declare -a clean_path
  clean_path=($(echo $path))

  # try three different expansions 
  if ! rm -Rr "${clean_path[@]}"; then
    if ! rm -Rr $clean_path; then
      if ! rm -Rr "$clean_path"; then
        msg::debug "Unable to remove $clean_path"
        _error "Unable to remove $clean_path"
      else 
        msg::debug "Managed to remove "$clean_path" (3)"
      fi
    else
      msg::debug "Managed to remove $clean_path (2)"
    fi
  else 
    msg::debug "Managed to remove "${clean_path[@]}" (1)"
  fi
}

#######################################
# Set system clock (needed in  virtual hosts)
#######################################
utils::set_clock(){
  if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
    if ! sudo hwclock --hctosys; then
      _error "Unable to set clock"
    fi
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
    _error "Unable to source $path"
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
# Return yaml keys
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 // a yaml variable ".variable.path"
#   $2 // an optional yaml file path
#######################################
utils::yaml_get_keys(){
  local var="${1-}"
  local path="${2:-"${YAML_PATH}"}"

  if [[ ! -f "${path}" ]]; then
    msg::debug "${EMOJI_STOP} No " "YAML file" " found"
  else
    if ! cat "${path}" | yq "${var}" | grep -v '^ .*' | sed 's/:.*$//'; then
      _error "Unable to yq ${var} in ${path}"
    fi
  fi
}

#######################################
# Return yaml values
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 // a yaml variable ".variable.path"
#   $2 // an optional yaml file path
#######################################
utils::yaml_get_values(){
  local var="${1-}" 
  local path="${2:-"${YAML_PATH}"}"
  local options="${3-}"
  local value

  # if file doesn't exist
  if [[ ! -f "${path}" ]]; then
    value=""
  
  # if a .yaml file is found
  else
    value=$(utils::yq "${var}" "${path}")
  fi

  # sends back the value
  utils::echo "${value}"
}

#######################################
# Check if a yaml selector is present in file
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 // a yaml selector ".variable.path"
#   $2 // a yaml file path
#######################################
utils::yq_has(){ 
  local selector="${1-}" 
  local yaml="${2-}"
  # local child_selector=$(utils::echo "${selector}" | grep -oE "[^.]+$")
  local child_selector=$(utils::echo "${selector}" | rev | cut -d. -f1 | rev)
  local parent_selector="${selector%."${child_selector}"}"
  
  # in the case where an array is asked
  if [[ "${child_selector}" == "[]" ]]; then
    child_selector=$(utils::echo "${selector}" | rev | cut -d. -f2 | rev)
    parent_selector="${selector%."${child_selector}.[]"}"
  fi
  
  local has_selector=""${parent_selector}" | has(\""${child_selector}"\")"
  local selector_exist=$(cat "${yaml}" | yq "${has_selector}") 

  if [[ "${selector_exist}" == false ]]; then
    # selector doesn't exist
    return 1
  elif [[ "${selector_exist}" == true ]]; then
    # selector does exist
    return 0
  fi
}

#######################################
# Return yaml values
# Arguments:
#   $1 // a yaml selector ".variable.path"
#   $2 // a yaml file path
#######################################
utils::yq(){
  # local options="${1-}"
  local selector="${1-}" 
  local yaml="${2-}"

  # check if selector exist in file
  utils::yq_has "${selector}" "${yaml}"

  # if yes, tries to recover value
  if (( $? != 0 )); then
    return 1
  # if not, propagates a 1 exit code
  else
    if ! cat "${yaml}" | yq "${selector}"; then
      echo "Unable to yq ${selector} in ${yaml}"
    fi
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
    _error "Unable to wget ${url}"
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
  local wget_options="-nc -q -P"
  local curl_options="--create-dirs -C - -JLOs --output-dir"
  if eval 'command -v wget' > /dev/null 2>&1; then
    msg::debug "wget is used"
    cmd::run_as_user "wget ${wget_options} " "${path}" "'"${url}"'"
  else
    msg::debug "curl is used"
    cmd::run_as_user "curl ${curl_options} " "${path}" "'"${url}"'"
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