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
    # save current $USER in a GLOBAL variable
    CURRENT_USER=$USER
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
# Arguments:
#   $1 # output visibility true / false
# Output:
#   ./src/temp/globals.conf
# Note : only methods from this file should be called.
#######################################
utils::check_operating_system(){
  # if a linux platform
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LOCO_OSTYPE="ubuntu"
    SHORT_OS_VERSION=$(lsb_release -r -s | cut -f1 -d'.')
    OS_PREFIX="home"
  # if a macos platform
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    LOCO_OSTYPE="macos"
    OS_PREFIX="Users"
    # check if mac has brew
    utils::mac_has_brew
    # check if mac has bash 4+
    utils::mac_has_bash
    # get version information, then grep version line, cut full semver, cut main version "e.g 12"
    SHORT_OS_VERSION=$(sw_vers | grep "ProductVersion:" | cut -f2 | cut -f1 -d'.')
  
  else 
    _error "Operating System not supported." 
    _exit "Operating System not supported."
  fi
  
  echo "LOCO_OSTYPE=${LOCO_OSTYPE}" > "./src/temp/conf_OS_GLOBALS"
  echo "SHORT_OS_VERSION=${SHORT_OS_VERSION}" >> "./src/temp/conf_OS_GLOBALS"
  echo "OS_PREFIX=${OS_PREFIX}" >> "./src/temp/conf_OS_GLOBALS"
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
      cmd::run_as_user "brew install yq"
    fi
  fi
  # if OVERLAY flag is set, 
  if [[ "${OVERLAY}" == true ]]; then
    if [[ $(command -v convert) ]]; then
      msg::say "imagemagick is installed."
    else
      msg::say "Installing imagemagick."
      if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
        apt --yes install imagemagick
      elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
        cmd::run_as_user "brew install imagemagick"
      fi
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
  # local seconds=$((1 * "${duration}"))
  local seconds="${duration}"
  while [ $seconds -gt 0 ]; do
    if [[ "${message}" != "" ]]; then
     echo -ne "${message}" "$seconds\033[0K\r"
    fi
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

  if ! cmd::run_as_user "cp -RL "${from}" "${to}""; then
    _error "Unable to copy ${from} in ${to}"
  fi
}

#######################################
# Chmod a path
# Arguments:
#   $1 # command argument "666 -R"
#   $2 # /path/to/
#######################################
utils::chmod(){
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
utils::chown(){
  local arg="${1-}"
  local path="${2-}"

  if ! chown "${arg}" ${path}; then
    _error "Unable to chown ${path} to ${arg}"
  fi
}

#######################################
# Cut a string
# Arguments:
#   $1 # a string ex: "Hello/world"
#   $2 # delimeter ex: "/"
#   $3 # part to be retrieved ex: "1"
#######################################
utils::string_cut(){
  local string="${1-}"
  local delimeter="${2-}"
  local part="${3-}"
  local command="echo "${string}" | cut -d "${delimeter}" -f "${part}""

  if ! cmd::run_as_user ${command}; then
    _error "Unable to cut ${string}"
  fi
}

#######################################
# Cut a string (reverse)
# Arguments:
#   $1 # a string ex: "Hello/world"
#   $2 # delimeter ex: "/"
#   $3 # part to be retrieved ex: "3"
#######################################
utils::string_cut_rev(){
  local string="${1-}"
  local delimeter="${2-}"
  local part="${3-}"
  local command="echo "${string}" | rev | cut -d "${delimeter}" -f "${part}" | rev"

  if ! cmd::run_as_user ${command}; then
    _error "Unable to reverse cut ${string}"
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
  # used in profile management
  PROFILE_YAML=""
  # used in package management
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
  # can be reset or defined at runtime
  # readonly CURRENT_USER
  # readonly PROFILE_YAML
  # readonly INSTANCE_YAML
  # readonly PROFILE_PATH
  # readonly INSTANCE_PATH
  # readonly SHORT_OS_VERSION
  # readonly ACTION
  # readonly PROFILE
  # readonly THEME
  # readonly BACKGROUND_URL
  # readonly IS_NEW_FONT

  readonly PROFILES_DIR
  readonly INSTANCES_DIR
  readonly CONFIG_PATH
  readonly WATERMARK
  readonly DETACHED
  readonly LOCO_YES
  readonly VERBOSE
  readonly VERSION
  readonly OS_PREFIX
  readonly SHORT_OS_VERSION
  readonly LOCO_OS_TYPE
}

#######################################
# Add a transparent image over another
# Arguments:
#   $1 # a normal image path
#   $2 # a transparent png path
#   $3 # is an optional output pathname
#######################################
utils::image_overlay(){
  local img_path="${1-}"
  local ovl_path="${2-}"
  local out_path="${3:-"img+overlay-output.jpg"}"
  local ratio_flag=false
  local img_sz
  local img_wd
  local img_ht
  local img_ratio

  # get the background width and height
  img_wd=$(identify -format '%w' "${img_path}")
  img_ht=$(identify -format '%h' "${img_path}")

  # calculate the background ratio
  img_ratio=$(bc <<< "scale=2; "${img_wd}"/"${img_ht}"")

  # if background ratio under 1.77 resize it
  if (( $(bc -l <<< "${img_ratio} < 1.77") )); then
    ratio_flag=true
    msg::print "Original background doesn't fit."
    msg::print "It will be backup'd and resized."
    # backup orginal background
    utils::cp "${img_path}" "${img_path}.temp"
    # modify original background resolution
    cmd::run_as_user "convert "${img_path}" -resize 3840x2160^ -gravity Center -extent 3840x2160 "${img_path}""
  fi 

  msg::debug "${ratio_flag}"

  # get the background width and height
  img_sz=$(identify -format '%wx%h' "${img_path}")

  # send background and overlay to imagemagick composite
  msg::print "Applying overlay to background image."
  cmd::run_as_user "convert -size "${img_sz}" -composite "${img_path}" "${ovl_path}" -geometry "${img_sz}""+0+0" -depth 8 "${out_path}""

  # restore original background and clean temp files
  if [[ "${ratio_flag}" == true ]]; then
    utils::remove "${img_path}"
    utils::cp "${img_path}.temp" "${img_path}"
    utils::remove "${img_path}.temp"
  fi
}

#######################################
# Create a symbolic link
# Arguments:
#   $1 # from /path/from/file
#   $2 # to /path/to/
# 
#######################################
utils::link(){
  local from="${1-}"
  local to="${2-}"

  if ! utils::run_as_user "ln -s "${from}" "${to}""; then
    _error "Unable to link "${from}" "${to}""
  fi
}

#######################################
# List files and folders within an array
# Arguments:
#   $1 # a normative array name
#   $2 # a path
#   $3 # an option [clear, hidden, all (default)]
# 
#######################################
utils::list(){
  local -n list_name="${1-}"
  local list_path="${2-}"
  local option="${3-"all"}"

  local paths
  local element_name

  # meant to clean a previously existing array
  list_name=()

  # check $option and set paths
  if [[ "${option}" == "all" ]]; then
    paths="${list_path}/.??* ${list_path}/*"
  elif [[ "${option}" == "clear" ]]; then
    paths="${list_path}/*"
  elif [[ "${option}" == "hidden" ]]; then
    paths="${list_path}/.??*"
  fi

  # prevail empty folders
  shopt -s nullglob

  # iterate over aguments paths
  for element_path in ${paths}; do
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
      echo -e "🌵 Homebrew needs to be installed."
      echo -e "🌵 Your password will be asked several times."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo -e "🌵 Homebrew is installed."
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
  if [[ ${BASH_VERSINFO[0]} -eq 3 ]];  then

    # if there is a binary in the brew/bash path
    if [[ -f /usr/local/bin/bash ]]; then
      echo -e "🌵 An other version of bash is installed."
      echo -e "🌵 You may want to use the command below:"
      echo -e "/usr/local/bin/bash ./loco"

    # if brew/bash is not installed
    else
      echo -e "🌵 Bash 4+ will be installed."
      $(brew install bash)
    fi
  else
    echo -e "🌵 Bash ${BASH_VERSINFO[0]} is installed."
  fi
}

#######################################
# Make a directory
# Arguments:
#   $1 # a path
#######################################
utils::mkdir(){
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
# Remove a file
# Arguments:
#   $1 # a file path
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
#   $1 # a path
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
# Replace a text block within a file
# Notes :
#   as the text block is a regex pattern within perl
#   special characters such as single and double quotes 
#   in "$3 # template content", must be escaped under their hex codes
#   e.g. \x27 for single quote and \x22 for double quotes
# Arguments:
#   $1 # template first part (beginning of searched string)
#   $2 # template last part (end of searched string)
#   $3 # template content
#   $4 # file to be modified path 
#######################################
utils::replace_in_file(){
  local template_first_part="${1-}"
  local template_last_part="${2-}"
  local new_content="${3-}"
  local file_path="${4-}"

  local search_pattern="${template_first_part}".*?"${template_last_part}"
  local search_and_replace='s/'"${search_pattern}"'/"'"${new_content}"'"/se'

  if ! perl -i -p0e "${search_and_replace}" "${file_path}"; then
    _error "Unable to replace text in "${file_path}""
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
#   $1 # a path
#   $2 # options
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
#   $1 # a yaml variable ".variable.path"
#   $2 # an optional yaml file path
#######################################
utils::yaml_get_keys(){
  local var="${1-}"
  local path="${2:-"${PROFILE_YAML}"}"

  if [[ ! -f "${path}" ]]; then
    msg::debug "${EMOJI_STOP} No " "YAML file" " found"
  else
    if ! cat "${path}" | yq "${var}" | grep -v '^ .*' | sed 's/:.*$//'; then
      _error "Unable to yq ${var} in ${path}"
    fi
  fi
}

#######################################
# Return yaml values (deprecated?)
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # a yaml file path
#######################################
utils::profile_get_values(){
  local var="${1-}" 
  local path="${2:-"${PROFILE_YAML}"}"
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
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
utils::yq_get(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}" 
  local value

  value=$(utils::yq2 "${yaml}" "${selector}")

  if [[ "${value}" == "" ]] || [[ "${value}" == "null" ]]; then
    return 1
  else
    utils::echo "${value}"
  fi
}


#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
utils::yq2(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}" 

  # check if selector exist in file
  # utils::yq_has_selector "${selector}" "${yaml}"
    # if yes, tries to recover value
  if ! cat "${yaml}" | yq "${selector}"; then
    echo "Unable to yq ${selector} in ${yaml}"
  fi
}


#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
utils::yq(){
  # local options="${1-}"
  local selector="${1-}" 
  local yaml="${2-}"

  # check if selector exist in file
  utils::yq_has_selector "${selector}" "${yaml}"

  # check if error code is 0
  if (( $? != 0 )); then
    # if not, propagates a 1 exit code
    return 1
  else
    # if yes, tries to recover value
    if ! cat "${yaml}" | yq "${selector}"; then
      echo "Unable to yq ${selector} in ${yaml}"
    fi
  fi
}

#######################################
# Check if a yaml selector is present in file
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
utils::yq_has_selector(){ 
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
# Return a boolean if value is found
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_contains(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"

  local yaml_value=$(utils::yq "${selector}" "${yaml}")
  
  if [[ "${yaml_value}" == *"${value}"* ]]; then
    echo true
  else
    echo false
  fi
}

#######################################
# Add a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_add(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"' = ["'"${value}"'"] + '"${selector}"

  # check if list value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # value already exist
    :
  else
      # tries to add list value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Delete a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_delete(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"'.[] | select(. == "'"${value}"'")'

  # check if list value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # tries to delete list value
    if ! cat "${yaml}" | yq 'del('"${arg}"')' > src/temp/yaml.local; then
      echo "Unable to yq delete ${selector}[${value}] in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Change a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_change(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"' = "'"${value}"'"'

  # check if value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # value already exist
    :
  else
      # tries to add value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Add a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#######################################
utils::yq_add_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  
  local arg="${selector}""${value}"' += []'

  # tries to add key
  # check if key exists already
  utils::yq_has_selector "${selector}""${value}" "${yaml}"
  if (( $? != 0 )); then
    # if the key desn't exist, create one
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add key ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Delete a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#######################################
utils::yq_delete_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  
  local arg='del('"${selector}""${value}"')'

  # tries to delete key
  # check if key exists already
  utils::yq_has_selector "${selector}""${value}" "${yaml}"

  if (( $? == 0 )); then
    # if the key exists, delete it
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq delete key ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#############################
# Wget a file in a folder. (deprecated in favor to utils::get_url)
# Arguments:
#   $1 # a path
#   $2 # an url
#######################################
# utils::wget(){
#   local path="${1-}"
#   local url="${2-}"
#   if ! cmd::run_as_user "wget -nc -q -P " "${path}" "${url}"; then
#     msg::debug "Unable to wget ${url}"
#     _error "Unable to wget ${url}"
#   fi
# }

#######################################
# Get a file from an URL into a folder.
# Arguments:
#   $1 # a folder path
#   $2 # an url
#######################################
utils::get_url(){
  local path="${1-}"
  local url="${2-}"
  local wget_options="-nc -q -P"
  local curl_options="--create-dirs -C - -LOs --output-dir"
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