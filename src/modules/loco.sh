#!/bin/bash
#-------------------------------------------------------------------------------
# loco.sh | loco.sh functions
#-------------------------------------------------------------------------------

#######################################
# Execute custom functions
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
    local action="$1"
    local custom_function="${ACTION}_${LOCO_OSTYPE}_custom_${action}"
    if [[ $(type -t "${custom_function}") == function ]]; then
      "${custom_function}"
    else
      msg::debug "No ${action} custom function found."
    fi
  else
    msg::debug "No custom.sh file found." 
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

#######################################
# Manage dotfiles installation or removal
# GLOBALS:
#   ACTION
#   LOCO_YES
#   LOCO_OSTYPE
# Arguments:
#   $1, 2, 3 # "This" "is a" "message"
#######################################
loco::dotfiles_manager(){
  msg::prompt "$1" "$2" "$3"
  case ${USER_ANSWER:0:1} in
  y|Y )
  # install PROFILE dotfiles
  local dotfiles_path="./"${PROFILES_DIR}"/"${PROFILE}"/dotfiles"
  # list profile dotfiles (shall be dumped/retrieved from/to .loco)
  utils::list dotfiles "${dotfiles_path}"
  msg::debug ${dotfiles[@]}
  # check if there are dotfiles in e $PROFILE
  if [[ -d "${dotfiles_path}" ]]; then
    # $ACTION == "install"
    if [[ "${ACTION}" == "install" ]]; then
      msg::print "${EMOJI_YES} Yes, use " "${PROFILE}" " dotfiles"
      msg::print "Preparing your dotfiles backup"
      INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
      mkdir -p ./"$INSTANCE_PATH/dotfiles-backup"
      local current_path=$(pwd) 
      msg::debug $current_path

      # backup $CURRENT_USER dotfiles and install $PROFILE
      for dotfile in "${dotfiles[@]}"; do
        # if the file exist, copy it
        if [ ! -f /home/"${CURRENT_USER}"/"${dotfile}" ]; then
          msg::debug "No corresponding file"
          else 
          msg::debug "${dotfile}" " is backup'd"
          cp -R /home/"${CURRENT_USER}"/"${dotfile}" ./"$INSTANCE_PATH"/dotfiles-backup/"${dotfile}"
        fi
        # remove existing file and then copy/link new one
        utils::remove "/home/""${CURRENT_USER}"/"${dotfile}"
        if [[ "${DETACHED}" == false ]]; then
          msg::debug "Not detached"
          ln -sfn "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
        else
          msg::debug "Detached"
          cp -R "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
        fi
      done
      msg::print "${CURRENT_USER}" " dotfiles were backup'd here :"
      msg::print "/"$INSTANCE_PATH"/dotfiles-backup"
    # $ACTION == "remove"
    elif [[ "${ACTION}" == "remove" ]]; then
      msg::print "${EMOJI_YES} Yes, remove " "${PROFILE}" " dotfiles"   
      msg::print "Removing " "${PROFILE}" " dotfiles"
      # remove $PROFILE dotfiles
      for dotfile in ${dotfiles[@]}; do
        utils::remove "/home/${CURRENT_USER}/${dotfile}"
      done
      # restore $CURRENT_USER dotfiles
      msg::print "Restoring " "${CURRENT_USER}" " dotfiles"
      if [[ -d ./"$INSTANCE_PATH"/dotfiles-backup ]]; then
        cmd::run_as_user "cp -R ./"$INSTANCE_PATH"/dotfiles-backup/." "/home/"${CURRENT_USER}"/" 
      else 
        msg::debug "No dotfiles to restore"
      fi
    fi
    # empty the normative list
    dotfiles=()
  fi
  ;;
  * )
    msg::print "${EMOJI_NO} No, I'll stick to " "current dotfiles"
  ;;
  esac
}

#######################################
# Manages fonts installation and removal
# Ref : https://www.linuxshelltips.com/export-import-gnome-terminal-profile/
# GLOBALS:
#   styles_fonts # yaml font array
# Arguments:
#   ACTION
#   PROFILE
#   styles_fonts ? global
# Output:
#   /home/$USER/.fonts/[fonts]
#######################################
loco::fonts_manager(){
  local font
  local yaml_fonts="${styles_fonts-}"
  local assets_fonts=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/
  local fonts_path=/home/"${CURRENT_USER}"/.fonts
  # check for yaml fonts
  if [[ -z "${yaml_fonts}" ]]; then
    msg::print "No YAML fonts found"
  else 
    # iterate over the yaml array 
    IFS=' ' read -r -a fonts_array <<< "${yaml_fonts}"  
    for i in "${fonts_array[@]}"; do
      font=${!i}

      # install yaml fonts
      if [[ "${ACTION}" == "install" ]]; then
        utils::mkdir "${fonts_path}"
        utils::wget "${fonts_path}" "${font}"
        # refresh fonts cache
        cmd::run_as_user "fc-cache -fr ""${fonts_path}"

      # remove yaml fonts
      elif [[ "${ACTION}" == "remove" ]]; then
        IFS='/' read -r -a font_path <<< "${font}"
        local font_name=${font_path[-1]}
        msg::debug "${font_name}"
        # get clean system path
        local font_name_clean=$(printf "%b\n" "${font_name//%/\\x}")
        msg::debug "${font_name_clean}"
        local font_path="${fonts_path}"/"${font_name_clean}"
        utils::remove ${font_path}
        cmd::run_as_user "fc-cache -fr ""${fonts_path}"
      fi
    done
  fi

  # check for /assets/fonts/ fonts
  if [[ -z "$(ls -A "${assets_fonts}" 2>/dev/null)" ]]; then
    msg::print "No /assets/fonts/ fonts found."
  else

    # install local fonts
    if [[ "${ACTION}" == "install" ]]; then
      utils::mkdir "${fonts_path}"
      local from_path=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/*
      local dest_path="${fonts_path}"
      utils::cp "${from_path}" "${dest_path}"

    # remove local fonts
    elif [[ "${ACTION}" == "remove" ]]; then
      # get a list of fonts as a bash array
      utils::list "fonts" "./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts"
      # loop over the local fonts list
      for font in "${fonts[@]}"; do
        local font_name_clean=$(printf "%b\n" "${font//%/\\x}")
        msg::debug "${font_name_clean}"
        local font_path="${fonts_path}"/"${font_name_clean}"
        # if the file exist, remove it
        if [[ ! -f "${font_path}" ]]; then
            msg::debug "Font not found."
          else 
            utils::remove "${font_path}"
        fi
      done
    fi
  fi
}

#######################################
# meta action: apply the defined cmd over the package
# GLOBALS:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::meta_action(){
  local local_package_action_cmd
  # if there isn't a specific command, build one
  if [[ -z "${PACKAGE_ACTION_CMD}" ]]; then 
    local_package_action_cmd="${PACKAGE_MANAGER} ${PACKAGE_ACTION} ${PACKAGE}"
    msg::debug "${local_package_action_cmd}"
    eval "${local_package_action_cmd}"
  # if there is a specific command, execute it
  else
    eval "${PACKAGE_ACTION_CMD}"
  fi
}

#######################################
# meta package: prepare package
# GLOBALS:
#   PACKAGE_MANAGER
#   PACKAGE_MANAGER_TEST_CMD
#   PACKAGE_ACTION
#   PACKAGE_ACTION_CMD
#   PACKAGE
#   ACTION
#######################################
loco::meta_package(){
  msg::debug "metaPackage ..."
  msg::debug ${PACKAGE_MANAGER}
  msg::debug ${PACKAGE_MANAGER_TEST_CMD} 
  msg::debug ${PACKAGE_ACTION}
  msg::debug ${PACKAGE_ACTION_CMD}
  msg::debug ${PACKAGE}
  local local_package_test_cmd

  #if no action is defined default to "${ACTION}"
  if [[ -z "${PACKAGE_ACTION}" ]]; then
    msg::debug "No package action"
    PACKAGE_ACTION="${ACTION}"
    msg::debug $PACKAGE_ACTION
  fi

  #check for test command options
  if [[ -z "${PACKAGE_TEST_CMD}" ]]; then
      msg::debug "No local test cmd"
    if [[ -z ${PACKAGE_MANAGER_TEST_CMD} ]]; then 
      msg::debug "No packager test cmd"
      # using the default testing command
      local_package_test_cmd='command -v $PACKAGE'
      msg::debug $local_package_test_cmd
    else
      #if $PACKAGE_MANAGER_TEST_CMD was populated, populate $local_package_test_cmd
      eval local_package_test_cmd=\$${PACKAGE_MANAGER_TEST_CMD}
      msg::debug "${local_package_test_cmd}"
    fi
  else
    #if $PACKAGE_TEST_CMD was populated, populate $local_package_test_cmd
    local_package_test_cmd="${PACKAGE_TEST_CMD}"
    msg::debug "${local_package_test_cmd}"
  fi

  # check for package status (installed/uninstalled) and act accordingly
  if eval "${local_package_test_cmd}" > /dev/null 2>&1; then
    msg::debug "${local_package_test_cmd}"
    msg::print "" "${PACKAGE_MANAGER} ${PACKAGE}" " is installed."
    # remove package
    if [[ "${ACTION}" == "remove" ]]; then
      msg::say "Removing " "${PACKAGE_MANAGER} ${PACKAGE}"
      loco::meta_action
    fi
  else
    msg::print "" "${PACKAGE}" " is not installed."
    # install package
    if [[ "${ACTION}" == "install" ]]; then
      msg::say "Installing " "${PACKAGE_MANAGER} ${PACKAGE}"
      loco::meta_action
    fi
  fi
  # clear global variables
  PACKAGE_TEST_CMD=""
  PACKAGE_ACTION_CMD=""
  PACKAGE_MANAGER_TEST_CMD=""
}

#######################################
# meta package manager: prepare package manager
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # defines the packages type
# Output:
#   Writes the bash variables file from yaml 
#######################################
loco::meta_package_manager(){
  msg::debug "meta_package_manager ..."
  # assign the $1 package managers
  local packagers="packages_"$1
  packagers="${!packagers-}"
  # check if packagers are declared
  if [[ -z "${packagers}" ]]; then
    msg::print "No " "$1" " package managers found"
  else
    # begin to assign values recursively from descriptors
    IFS=' ' read -r -a packagers_array <<< "${packagers}"
    for i in "${packagers_array[@]}"; do  

      # prepare variables from package manager descriptor
      PACKAGE_ACTION="${ACTION}"

      # parse to identify package manager name
      IFS='_' read -r -a local_packager_name <<< "${i}" 
      local packager_path="./src/descriptors/${local_packager_name[-1]}.sh"
      # check for descriptor file
      if [[ ! -f  "${packager_path}" ]]; then
        msg::print "No " "$1" " package manager descriptor found"
      else
        # if a file, source it
        if ! source "${packager_path}"; then
          echo "Can not source ${packager_path}" >&2
          exit 1
        fi
        # expand variable value 
        PACKAGE_ACTION=${!PACKAGE_ACTION}   
        # update the package manager
        ${PACKAGE_MANAGER} ${update}

        # parse to get packages names
        local packages=${!i}
        IFS=' ' read -r -a packages_array <<< "${packages}"   

        # send packages names to metaPackage
        for i in "${packages_array[@]}"; do
          PACKAGE=${!i}
          loco::meta_package "${PACKAGE}" "${PACKAGE_MANAGER_TEST_CMD}" ;
        done
      fi
    done
  fi
}

#######################################
# Call the startup functions.
# Globals:
#   CONFIG_PATH
#   IS_ROOT
#   ACTION
# Arguments:
#   $@ just in case
#######################################
loco::startup(){
  # remove temp files
  utils::clean_temp

  # set system clock
  utils::set_clock

  # detect and check if OS is supported
  utils::check_operating_system  

  # externally source the yaml parser 
  # https://github.com/mrbaseman/parse_yaml
  utils::yaml_source_parser

  # print the warning message
  msg::warning

  # build and source the actions prompt file, if there is no option set
  if [ -z "$ACTION" ]; then
    prompt::build "ACTION" "./src/actions" "What do you want to do ?"
    prompt::call "ACTION" "./src/actions" "What do you want to do ?"
  fi  
}

#######################################
# Build terminal style file.
# note : Setting dconf for a specific user thorugh terminal,
# can only be achieved with root rights (su, not sudo).
# GLOBALS:
#   PROFILES
#   PROFILES_DIR
#   ACTION
#######################################
loco::term_conf_set(){
  local dist_path=""
  local local_path=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  local distro_path=./"${dist_path}""${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  local gnome_path="/org/gnome/terminal/legacy/profiles:/"
  local gnome_UUID="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"

  # check if current loco is remote installation
  if [[ "${LOCO_DIST}" == true ]]; then
    dist_path=loco-dist/
  fi

  # check if a terminal configuration is present
  if [[ ! -f "${local_path}" ]]; then
    msg::print "No terminal configuration file found"
  else
    # if yes, print command to install / remove it
    if [[ "${ACTION}" == "install" ]]; then
      cmd::record "dconf load "${gnome_path}":"${gnome_UUID}"/ < ""${distro_path}"
    elif [[ "${ACTION}" == "remove" ]]; then
      cmd::record "dconf reset -f "${gnome_path}""
    fi
  fi
}

#######################################
# Check for watermark presence
# GLOBALS:
#   CURRENT_USER
#   ACTION
#   PROFILE
#   INSTANCE_PATH
#   EMOJI_YES
#   EMOJI_NO
#######################################
loco::watermark_check(){
  local current_profile="${PROFILE}"
  if [[ ! -f /home/"${CURRENT_USER}"/.loco ]]; then
    msg::print "No " "previous instance" " found."
    if [[ "${ACTION}" == "remove" ]]; then
      exit
    fi
  else 
    if [[ "${ACTION}" == "install" ]]; then
      msg::print "${EMOJI_STOP} There is a " "${CURRENT_USER}" " watermark."
      msg::print "" "Please, remove this instance first."
      msg::prompt "Remove the installed instance ?"
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES}" " Yes, remove instance."
        # switch to remove
        ACTION="remove"
        utils::source ./src/actions/"${ACTION}".sh
        # switch back to installation
        # remove temp loco_finish.sh
        utils::remove "./src/temp/loco_finish.sh"
        ACTION="install"
        PROFILE="${current_profile}"
      ;;
      * )
        msg::print "${EMOJI_NO}" " No, I'll keep current instance."
        exit;
      ;;
      esac
    elif [[ "${ACTION}" == "remove" ]]; then
      utils::source /home/"${CURRENT_USER}"/.loco
      msg::print "Profile to be removed : " "${PROFILE}"
      msg::print "User to be restored : " "${CURRENT_USER}"
      msg::print "Dotfiles path to be restored : " "${INSTANCE_PATH}"
    fi
  fi
}

#######################################
# set / unset a post script watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   INSTANCE_PATH
#   WATERMARK
#   ACTION
# Output:
#   Writes/rm .loco file to /home/
#######################################
loco::watermark_set(){
  if [[ "${ACTION}" == "remove" ]]; then
    msg::say "Removing " "watermark"
    rm /home/${CURRENT_USER}/.loco
  elif [[ "${WATERMARK}" == true ]]; then
    echo '#loco.sh instance infos...' > /home/"${CURRENT_USER}"/.loco
    echo 'CURRENT_USER='${CURRENT_USER} >> /home/"${CURRENT_USER}"/.loco
    echo 'PROFILE='${PROFILE} >> /home/"${CURRENT_USER}"/.loco
    echo 'INSTANCE_PATH='${INSTANCE_PATH-} >> /home/"${CURRENT_USER}"/.loco
    if (( $? != 0 )); then
      echo "Unable to source "${CONFIG_PATH}"" >&2
    fi
  fi
}

#######################################
# Build and source the profiles yaml.
# Globals:
#   PROFILE
#   PROFILES_DIR
# Output:
#   ./src/temp/"${PROFILE}"_yaml_variables.sh
#######################################
loco::yaml_profile(){
  local yaml_path="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
  local destination_path="./src/temp/"${PROFILE}"_yaml_variables.sh"
  utils::yaml_read "${yaml_path}" "${destination_path}"
}