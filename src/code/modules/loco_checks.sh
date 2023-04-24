#!/bin/bash
#-------------------------------------------------------------------------------
# loco_checks.sh | checking functions
#-------------------------------------------------------------------------------

#######################################
# Check if the current user is root
# Output:
#   ./src/temp/conf_is_start
#######################################
loco::check_if_start(){
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
loco::check_if_root(){
  if [[ "${ROOT_YES}" == false ]]; then
    if [[ "${IS_ROOT}" -ne 0 ]]; then
      msg::centered ""
      msg::centered 'Password is needed to run this script as "sudo"'
      msg::centered ""
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
      _source ./src/temp/conf_CURRENT_USER
    fi
  fi
}

#######################################
# For macOS check if brew is installed or install it
# GLOBALS:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::mac_has_brew(){
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
loco::mac_has_bash(){
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
      /usr/local/bin/brew install bash
    fi
  else
    echo -e "🌵 Bash ${BASH_VERSINFO[0]} is installed."
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
loco::check_operating_system(){
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
    loco::mac_has_brew
    # check if mac has bash 4+
    loco::mac_has_bash
    # get version information, then grep version line, cut full semver, cut main version "e.g 12"
    SHORT_OS_VERSION=$(sw_vers | grep "ProductVersion:" | cut -f3 | cut -f1 -d'.')
  
  else 
    _error "Operating System not supported." 
    _exit "Operating System not supported."
  fi
  
  if [[ -d ./src/temp ]]; then
    :
  else
    if ! mkdir "./src/temp"; then
      echo "Can not create temp folder"
    fi
  fi

  _echo "LOCO_OSTYPE=${LOCO_OSTYPE}" > "./src/temp/conf_OS_GLOBALS"
  _echo "SHORT_OS_VERSION=${SHORT_OS_VERSION}" >> "./src/temp/conf_OS_GLOBALS"
  _echo "OS_PREFIX=${OS_PREFIX}" >> "./src/temp/conf_OS_GLOBALS"
}

#######################################
# Check if dependencies are met
# GLOBALS:
#   LOCO_OS_VERSION
#######################################
loco::check_dependencies(){
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