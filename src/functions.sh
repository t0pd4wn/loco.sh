#!/bin/bash
#-------------------------------------------------------------------------------
# functions.sh | functions
#-------------------------------------------------------------------------------

#######################################
# main
# Arguments:
#   ACTION
#   LOCO_OSTYPE
#   $@ just in case
#######################################
main(){
  # launch startup checks and utils
  loco::startup "$@"
  # source action script
  source ./src/actions/"${ACTION}".sh
  # end
  cmd::play
  msg::end
  trap 'loco::custom_last' 0
  exit $?
}

#######################################
# Build cli file
# Globals :
#   CLI_OPT_PARAMETERS
#   CLI_OPT_DESCRIPTIONS
#   HELP_TEXT
# Output:
#   ./src/temp/cli.sh
#######################################
cli::build(){
  local cli_file="./src/temp/cli.sh"
  local joined_parameters
  local joined_descriptions
  # build file
  joined_parameters=$(IFS=; echo "${CLI_OPT_PARAMETERS[*]}");
  joined_descriptions=$(IFS=; echo "${CLI_OPT_DESCRIPTIONS[*]}");
  echo "while getopts """${joined_parameters}""" flag" > "${cli_file}"
  echo "do" >> "${cli_file}"
  echo "case "'"${flag}"'" in" >> "${cli_file}"
  echo -e "${joined_descriptions}" >> "${cli_file}"              
  echo "esac" >> "${cli_file}"
  echo "done" >> "${cli_file}"
}

#######################################
# Call the cli
# Globals:
#   LOCO_LOGO
#   VERSION
#######################################
cli::call(){
  if ! source ./src/temp/cli.sh; then
    echo "Can not source cli.sh" >&2
    exit 1
  fi
}

#######################################
# Set cli options and GLOBALS
# Globals :
#   CLI_OPT_PARAMETERS
#   CLI_OPT_DESCRIPTIONS
#   HELP_TEXT
# Arguments:
#   $1 # the option associative array 
#######################################
cli::define_option(){
  local -n opt_arr="$1"
  local opt_desc
  local hlp_txt

  # instanciate GLOBAL variable and assign value
  printf -v "${opt_arr["GLOBAL"]}" '%s' "${opt_arr["default"]}"

  # define variable command parameters and options
  CLI_OPT_PARAMETERS+=("${opt_arr["option"]}")

  # check for ":" in opt parameter, if yes ask for an option, if not, CMD
  if [[ ${opt_arr["option"]} =~ ":" ]]; then
      opt_desc="${opt_arr["option"]//:}"") ""${opt_arr["GLOBAL"]}"'=${OPTARG};;\n'
  else
      opt_desc="${opt_arr["option"]}"") ""${opt_arr["CMD"]}"';;\n'
  fi

  CLI_OPT_DESCRIPTIONS+=("${opt_desc}")
  # fills help text
  hlp_txt="${opt_arr["option"]//:}"" | ""${opt_arr["description"]}"'\n'
  HELP_TEXT+=("${hlp_txt}")
}

#######################################
# Print the help text.
# Globals :
#   HELP_TEXT
#######################################
cli::print_help(){
  local joined_help_text
  joined_help_text=$(IFS=; echo "${HELP_TEXT[*]}");
  echo -e "${joined_help_text}"
  echo -e "loco.sh ${EMOJI_LOGO}"
}

#######################################
# Print the version number.
# Globals:
#   LOCO_LOGO
#   VERSION
#######################################
cli::print_version(){
  echo -e "loco.sh ${EMOJI_LOGO} version ${VERSION}"
}

#######################################
# Register cli options
# GLOBALS:
#   ACTION
#   PROFILE
#   CURRENT_USER
#   PROFILES_DIR
#   INSTANCES_DIR
#   CONFIG_PATH
#   WATERMARK
#   DETACHED
#   HELP
#   VERSION
#   VERBOSE
#   LOCO_YES
#   ROOT_YES
#   LOCO_DIST
#######################################
cli::set_options(){
  declare -A action_opt_array
  action_opt_array=(
    [GLOBAL]="ACTION"
    [option]="a:"
    [description]="Define the loco action."
    [default]=""
    [CMD]=""
  )
  cli::define_option action_opt_array

  declare -A profile_opt_array
  profile_opt_array=(
    [GLOBAL]="PROFILE"
    [option]="p:"
    [description]="Define the target profile dirname."
    [default]=""
    [CMD]=""
  )
  cli::define_option profile_opt_array

  declare -A current_user_opt_array
  current_user_opt_array=(
    [GLOBAL]="CURRENT_USER"
    [option]="u:"
    [description]="Define the name of the current user (default : \`\$USER\`)."
    [default]="$USER"
    [CMD]=""
  )
  cli::define_option current_user_opt_array

  declare -A profiles_dir_opt_array
  profiles_dir_opt_array=(
    [GLOBAL]="PROFILES_DIR"
    [option]="d:"
    [description]="Define the dir_name for profiles directories."
    [default]="profiles"
    [CMD]=""
  )
  cli::define_option profiles_dir_opt_array

  declare -A instances_dir_opt_array
  instances_dir_opt_array=(
    [GLOBAL]="INSTANCES_DIR" 
    [option]="i:"
    [description]="Define the path for backup instances."
    [default]="instances"
    [CMD]=""
  )
  cli::define_option instances_dir_opt_array

  declare -A config_path_opt_array
  config_path_opt_array=(
    [GLOBAL]="CONFIG_PATH"
    [option]="c:"
    [description]="Define the path to the configuration file"
    [default]="./src/loco.conf"
    [CMD]=""
  )
  cli::define_option config_path_opt_array

  declare -A watermark_opt_array
  watermark_opt_array=(
    [GLOBAL]="WATERMARK"
    [option]="w:"
    [description]="Define if loco watermark is set (needed for some actions)."
    [default]=true
    [CMD]=""
  )
  cli::define_option watermark_opt_array

  declare -A detached_flag_array
  detached_flag_array=(
    [GLOBAL]="DETACHED"
    [option]="D"
    [description]="Define if dotfiles are symlinked (false) or copied (true)."
    [default]=false
    [CMD]="DETACHED=true"
  )
  cli::define_option detached_flag_array

  declare -A help_flag_array
  help_flag_array=(
    [GLOBAL]="HELP"
    [option]="h"
    [description]="Display help menu"
    [default]=""
    [CMD]="cli::print_help\nexit"
  )
  cli::define_option help_flag_array

  declare -A version_flag_array
  version_flag_array=(
    [GLOBAL]="VERSION"
    [option]="v"
    [description]="Print Version Number"
    [default]="0.2"
    [CMD]="cli::print_version\nexit"
  )
  cli::define_option version_flag_array

  declare -A verbose_flag_array
  verbose_flag_array=(
    [GLOBAL]="VERBOSE"
    [option]="V"
    [description]="Verbose mode"
    [default]=false
    [CMD]="VERBOSE=true"
  )
  cli::define_option verbose_flag_array

  declare -A yes_flag_array
  yes_flag_array=(
    [GLOBAL]="LOCO_YES"
    [option]="Y"
    [description]="Automate the yes answer (the few left)"
    [default]=false
    [CMD]="LOCO_YES=true"
  )
  cli::define_option yes_flag_array

  declare -A root_flag_array
  root_flag_array=(
    [GLOBAL]="ROOT_YES"
    [option]="R"
    [description]="Automate the SUDO answer"
    [default]=false
    [CMD]="ROOT_YES=true"
  )
  cli::define_option root_flag_array

  declare -A dist_flag_array
  dist_flag_array=(
    [GLOBAL]="LOCO_DIST"
    [option]="J"
    [description]="Modify ./path/ if remote installation"
    [default]=false
    [CMD]="LOCO_DIST=true"
  )
  cli::define_option dist_flag_array
}

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
  local script_path="./src/temp/loco_finish.sh"
  if [[ -f "${script_path}" ]]; then
    msg::record 'type `./src/temp/loco_finish.sh` to finish installation'
  fi
}

#######################################
# Runs a command as current user
# Globals:
# Argumsnts:
#   $1 // a command
#######################################
cmd::run_as_user(){
  local command="$@"
  msg::debug "${command}"
  su "${CURRENT_USER}" -c "${command}"
}


#######################################
# Build a prompt shell file
# Arguments:
#   $1 // action 
# Output:
#   ./src/prompts/prompt_$1.sh
#######################################
prompt::build(){
  local local_GLOBAL="$1"
  local local_dir="$2"
  local local_prompt_message="$3"
  local file_basename
  local prompt_index
  local prompt_option
  local prompt_option_name
  local prompt_options
  local prompt_path=./src/temp/prompt_"${local_GLOBAL}".sh
  declare -a argCases
  prompt_index=0
  for FILE in "${local_dir}"/*; do
    prompt_index=$((prompt_index+1))
    file_basename=$(basename "${FILE}")
    prompt_option=$(echo $file_basename | cut -f 1 -d '.')
    prompt_option_name="$(tr '[:lower:]' '[:upper:]' <<< ${prompt_option:0:1})${prompt_option:1}"
    prompt_options+="${prompt_option_name} "
    argCases+="$prompt_index) printf -v ""${local_GLOBAL}"" '%s' "${prompt_option}";;\n"
  done
  # build prompt file
  echo "title=\"$(msg::say "${local_prompt_message}")\"" > "${prompt_path}"
  echo "prompt=\"$(msg::print "Pick an option : ")\"" >> "${prompt_path}"
  echo "options=("$prompt_options")" >> "${prompt_path}"
  echo "echo \$title" >> "${prompt_path}"
  echo "PS3=\$prompt" >> "${prompt_path}"
  echo "select opt in "'"${options[@]}"'" "Quit"; do " >> "${prompt_path}"
  echo "case "\$REPLY" in" >> "${prompt_path}"
  echo -e "$argCases" >> "${prompt_path}"
  echo "$((prompt_index+1))) echo "Goodbye!"; exit;;" >> "${prompt_path}"
  echo "*) echo "Invalid option. Try another one.";continue;;" >> "${prompt_path}"
  echo "esac" >> "${prompt_path}"
  echo "break" >> "${prompt_path}"
  echo "done" >> "${prompt_path}"
}

#######################################
# Call a prompt file
# Arguments:
#   $1 // path_suffix
#######################################
prompt::call(){
  local path_suffix="$1"
  # source built file
  if ! source ./src/temp/prompt_"${path_suffix}".sh; then 
    echo "Can not source prompt file" >&2
  fi
}

#######################################
# Execute custom functions
# GLOBALS
#   ACTION
#   LOCO_OSTYPE
#   PROFILE
#   PROFILES_DIR
# Arguments
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
    msg::print "No custom.sh file found." 
  fi
}

#######################################
# Source and execute entry custom functions
# GLOBALS
#   PROFILE
#######################################
loco::custom_entry(){
  # source custom.sh
  # source "${PROFILE}" custom functions
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
# Globals:
#   PROFILE
#   PROFILES_DIR
#######################################
loco::custom_source(){
  if ! source "./"${PROFILES_DIR}"/"${PROFILE}"/custom.sh"; then
    msg::print "No custom.sh file found."
    echo "Unable to source ./"${PROFILES_DIR}"/${PROFILE}/custom.sh" >&2
  fi
}

#######################################
# Manage dotfiles installation or removal
# GLOBALS
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
    local dotfiles_backup_list="./src/temp/loco_dotfiles_backup_list"

    if [[ "${ACTION}" == "install" ]]; then
      msg::print "${EMOJI_YES} Yes, use " "${PROFILE}" " dotfiles"
      msg::print "Preparing your dotfiles backup"
      INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
      mkdir -p ./"$INSTANCE_PATH"

      if [[ -d "${dotfiles_path}" ]]; then
        # list profiles dotfiles and keep a list (shall be dumped to .loco)
        ls -a "${dotfiles_path}" > "${dotfiles_backup_list}"
        sed -i -e '1,2d' "${dotfiles_backup_list}"
        
        msg::print "${CURRENT_USER}" " dotfiles are getting backup'd"
        mkdir -p ./"$INSTANCE_PATH"/dotfiles-backup
        
        # check if dotfile exist then backup
        while read dotfile || [[ -n "${dotfile}" ]] ; do 
          msg::debug "${dotfile}"
          if [ ! -f /home/"${CURRENT_USER}"/$dotfile ]; then
              msg::debug "No corresponding file"
            else 
            cp -R /home/"${CURRENT_USER}"/"${dotfile}" ./"$INSTANCE_PATH"/dotfiles-backup
          fi
        done < "${dotfiles_backup_list}"   

        msg::print "${CURRENT_USER}" " dotfiles were backup'd here :"
        msg::print "/"$INSTANCE_PATH"/dotfiles-backup"  
        local current_path=$(pwd) 
        while read dotfile || [[ -n "${dotfile}" ]] ; do
          msg::debug "${LOCO_YES}"
          msg::debug "${DETACHED}"
          if [[ "${DETACHED}" == false ]]; then
            msg::debug "not detached"
            rm -fR /home/"${CURRENT_USER}"/"${dotfile}"
            ln -sfn "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
          else
            msg::debug "detached"
            rm -fR /home/"${CURRENT_USER}"/"${dotfile}"
            cp -R "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
          fi
        done < "${dotfiles_backup_list}"
      fi
    # remove PROFILE dotfiles
    elif [[ "${ACTION}" == "remove" ]]; then
      if [[ -d "${dotfiles_path}" ]]; then
        msg::print "${EMOJI_YES} Yes, remove " "${PROFILE}" " dotfiles"   
        msg::print "Removing " "${PROFILE}" " dotfiles"
        # implement get_dir_list??
        ls -a ./"${PROFILES_DIR}"/"${PROFILE}"/dotfiles > "${dotfiles_backup_list}"
        sed -i -e '1,2d' "${dotfiles_backup_list}"
        while read dotfile || [ -n "$dotfile" ] ; do 
        # unset -eu
        set +eu
        rm -r /home/${CURRENT_USER}/$dotfile;
        # if ! rm -r /home/${CURRENT_USER}/$dotfile; then
        #   echo "Can not rm -r /home/${CURRENT_USER}/$dotfile" >&2
        #   exit 1
        # fi
        # set back -eu
        set -eu
        done < "${dotfiles_backup_list}"  
        msg::print "Restoring " "${CURRENT_USER}" " dotfiles"
        cp -R ./"$INSTANCE_PATH"/dotfiles-backup/. /home/"${CURRENT_USER}"/ 
      fi
    fi
    ;;
    * )
      msg::print "${EMOJI_NO} No, I'll stick to " "current dotfiles"
    ;;
    esac
}

#######################################
# Manages fonts installation and removal
# Arguments:
#   ACTION
#   PROFILE
#   styles_fonts ? global
# Output:
# /usr/share/fonts/truetype/[fonts]
#######################################
loco::fonts_manager(){
  local font
  local yaml_fonts="${styles_fonts-}"
  local fonts_path=/home/"${CURRENT_USER}"/.fonts
  # check for yaml fonts
  if [[ -z "${yaml_fonts}" ]]; then
    msg::print "No YAML fonts found"
  else 
    # iterate over the yaml array 
    IFS=' ' read -r -a fonts_array <<< "${yaml_fonts}"  
    for i in "${fonts_array[@]}"; do
      font=${!i}
      if [[ "${ACTION}" == "install" ]]; then
        # install yaml fonts
        mkdir -p "${fonts_path}"
        wget -nc -P "${fonts_path}" "${font}"
      elif [[ "${ACTION}" == "remove" ]]; then
        # remove yaml fonts
        IFS='/' read -r -a font_path <<< "${font}"
        local font_name=${font_path[-1]}
        msg::debug "${font_name}"
        # get clean system path
        local font_name_clean=$(printf "%b\n" "${font_name//%/\\x}")
        msg::debug "${font_name_clean}"
        sudo rm "${fonts_path}"/"${font_name_clean}"
      fi
    done
  fi

  # check for local fonts
  if [[ $(ls -A "./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/") ]]; then
    # install local fonts
    if [[ "${ACTION}" == "install" ]]; then 
      local fonts_path=/home/"${CURRENT_USER}"/.fonts
      mkdir -p "${fonts_path}"
      sudo cp -r ./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/* "${fonts_path}"
    # remove local fonts
    elif [[ "${ACTION}" == "remove" ]]; then
      ls -a ./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts > ./src/temp/"${PROFILE}"_local_fonts_list
      sed -i -e '1,2d' ./src/temp/"${PROFILE}"_local_fonts_list
      while read font || [ -n "${font}" ] ; do 
        if [[ ! -f "${fonts_path}"/"${font}" ]]; then
            msg::debug "Font not found."
          else 
          if ! rm "${fonts_path}"/"${font}"; then
              echo "Unable to delete fonts "${fonts_path}"/"${font}"" >&2
            fi
        fi
      done < ./src/temp/"${PROFILE}"_local_fonts_list
    fi
  else 
    msg::print "No assets folder fonts found."
  fi
}

#######################################
# meta action : apply the defined cmd over the package
# Arguments:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::meta_action(){
  local local_package_action_cmd
  if [[ -z "${PACKAGE_ACTION_CMD}" ]]; then 
    local_package_action_cmd="${PACKAGE_MANAGER} ${PACKAGE_ACTION} ${PACKAGE}"
    msg::debug "${local_package_action_cmd}"
    eval "${local_package_action_cmd}"
  else
    eval "${PACKAGE_ACTION_CMD}"
  fi
}

#######################################
# meta package : prepare package
# Arguments:
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

  # check for package status and act accordingly
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
# Meta package manager : prepare package manager
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 // defines the packages type
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
        
        # special condition to update apt after ppa installation
        if [[ ${local_packager_name[-1]} == "ppa" ]]; then
          sudo apt update
        fi
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

  # detect and check if OS is supported
  utils::check_operating_system  

  # externally source the yaml parser "https://github.com/mrbaseman/parse_yaml"
  utils::source_parse_yaml

  # load default or user conf
  if ! source "${CONFIG_PATH}"; then
      echo "Unable to source "${CONFIG_PATH}"" >&2
  fi

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
# GLOBALS
#   PROFILES
#   PROFILES_DIR
# Arguments:
#   ACTION
# Output:
#   ./src/temp/loco-term.sh
#   ./src/temp/loco-term-reset.sh
#######################################
loco::term_conf_set(){
  # note : Apparently, it is possible to set dconf for a specific user.
  # This can be achieved with root rights (su, not sudo)
  # check if current loco is remote installation
  local is_dist="${LOCO_DIST}"
  local dist_path=""
  if [[ "${is_dist}" == true ]]; then
    dist_path="loco-dist/"
  fi
  # create path
  local term_conf_path="./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf"
  if [[ ! -f "${term_conf_path}" ]]; then
    msg::print "No terminal configuration file found"
  else
    if [[ "${ACTION}" == "install" ]]; then
      local term_path="./"${dist_path}""${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf"
      cmd::record 'dconf load /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ < '"${term_path}"
      # echo 'dconf load /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ < '"${term_path}" > ./src/temp/loco-term.sh
      # chmod +x ./src/temp/loco-term.sh
      # msg::record 'type `./'"${dist_path}"'src/temp/loco-term.sh` to set your terminal style' 

    elif [[ "${ACTION}" == "remove" ]]; then
      cmd::record 'dconf reset -f /org/gnome/terminal/legacy/profiles:/'
      # cmd::record 'dconf reset -f /org/gnome/terminal/legacy/profiles:/' > ./src/temp/loco-term-reset.sh
      # chmod +x ./src/temp/loco-term-reset.sh
      # msg::record 'type `./'"${dist_path}"'src/temp/loco-term-reset.sh` to reset terminal'
    fi
  fi
}


#######################################
# Build and source the profiles yaml.
# Globals:
#   PROFILE
#   PROFILES_DIR
# Output:
#   Writes the bash variables file from yaml 
#######################################
loco::yaml_read(){
  local destination_path="./src/temp/"${PROFILE}"_yaml_variables.sh"
  local yaml_path="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"

  # check if file exist
  if [[ ! -f "${yaml_path}" ]]; then
    msg::print "${EMOJI_STOP} No " "YAML file" " found" >&2
  else
    # parse the $PROFILE yaml
    if ! parse_yaml "${yaml_path}" "" > "${destination_path}"; then
      echo "Unable to parse YAML" >&2
    fi
    # clean the result file
    sed -i 's/_=" /_="/g' "${destination_path}"
    sed -i 's/_="/="/g' "${destination_path}"
    if (( $? != 0 )); then
      echo "Unable to sed ${destination_path}" >&2
    fi
    # source the result file
    if ! source "${destination_path}"; then
      echo "Unable to source ${destination_path}" >&2
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
      source ./src/actions/"${ACTION}".sh
      # switch back to installation
      ACTION="install"
    ;;
    * )
      msg::print "${EMOJI_NO}" " No, I'll keep current instance."
      exit;
    ;;
    esac
  elif [[ "${ACTION}" == "remove" ]]; then
    source /home/"${CURRENT_USER}"/.loco
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
    echo 'INSTANCE_PATH='${INSTANCE_PATH} >> /home/"${CURRENT_USER}"/.loco
    if (( $? != 0 )); then
      echo "Unable to source "${CONFIG_PATH}"" >&2
    fi
  fi
}

#######################################
# Print a debug message
# GLOBALS
#   VERBOSE
#   BOLD
#   NORMAL
# Arguments:
#   $@ # "This is a message."
#######################################
msg::debug(){
  if [[ "${VERBOSE}" == true ]]; then
    echo "${BOLD}DEBUG : ${BASH_LINENO[0]} ... ${NORMAL} $@ "${NORMAL}
  fi
}

#######################################
# Record messages
# GLOBALS :
#   MSG_ARRAY
#   MSG_INDEX
# Arguments:
#   $1
#######################################
msg::record(){
  MSG_INDEX+=1;
  MSG_ARRAY[MSG_INDEX]=$1;
}

#######################################
# Play recorded messages
# GLOBALS :
#   MSG_ARRAY
#######################################
msg::play(){
  for i in "${MSG_ARRAY[@]}"; do msg::say "$i"; done
  MSG_ARRAY=();
}

#######################################
# Print a templated message
# Arguments:
# $1, 2, 3
#######################################
msg::print(){
  echo -e "${NORMAL}"${1-}"${BOLD}"${2-}"${NORMAL}"${3-}"${NORMAL}"
}

#######################################
# Print a prompt message
# GLOBALS
#   USER_ANSWER
#   LOCO_YES
# Arguments:
#   $1,2,3 # "This" "is a" "message"
# Output:
#   A yes / no answer in USER_ANSWER
#######################################
msg::prompt(){
  local prompt_message
    prompt_message=$(msg::print "${1-}" "${2-}" "${3-}")# 
    # if "${LOCO_YES}" global flag is set, automatically answers y
    if [[ "${LOCO_YES}" == true ]]; then 
      USER_ANSWER="y"
      yes | read -p "$prompt_message" USER_ANSWER
    # if not, asks
    else 
      read -p "$prompt_message" USER_ANSWER
    fi
}

#######################################
# Print a templated message with the LOCO logo
# Arguments:
# $1, 2, 3
#######################################
msg::say(){
  local start_text="${EMOJI_LOGO} ${1-}"
  msg::print "${start_text}" "${2-}" "${3-}"
}

#######################################
# Print the start message
# GLOBALS
#   EMOJI_LOGO
#   VERSION
#   CURRENT_USER
#######################################
msg::start(){
  # loco starts
  msg::print "................................................................"
  msg::print "................................................................"
  msg::print "...................." "Welcome to loco.sh ${EMOJI_LOGO} ${VERSION}" "..................."
  CURRENT_USER=$USER
}

#######################################
# Print the warning message
# GLOBALS
#   LOCO_STOP
#######################################
msg::warning(){
  msg::print "................................................................"
  msg::print "................................................................"
  msg::print "........ ${EMOJI_STOP} " "Modifying packages can break your system." " ${EMOJI_STOP} ......."
  msg::print "..................Proceed at " "your own risks." "...................."
  msg::print "................................................................"
  msg::print "................................................................"
}

#######################################
# Print the end message
# GLOBALS
#   VERBOSE
#   LOCO_LOGO
#   VERSION
#######################################
msg::end(){
  if [[ "${VERBOSE}" == false ]]; then
    clear
  fi
  msg::print "................................................................"
  msg::print "................................................................"
  msg::print "...............Thank you for using " "loco.sh " "${EMOJI_LOGO} ${VERSION}..............."
  msg::print "................................................................"
  msg::print "................................................................"
  #print exit function message(s)
  msg::play
  msg::print "................................................................"
  msg::print "................................................................"
}  

#######################################
# Download and source the parse_yaml script.
#######################################
utils::source_parse_yaml(){
  # if true, keep a copy locally
  local cache_flag=true

  # wget parse_yaml "https://github.com/mrbaseman/parse_yaml"
  wget -nc -q -P ./src/temp/ https://raw.githubusercontent.com/mrbaseman/parse_yaml/master/src/parse_yaml.sh 
  if (( $? != 0 )); then
        echo "Unable to wget parse_yaml" >&2
    fi
    # source file
  if ! source ./src/temp/parse_yaml.sh; then
    echo "Unable to source ./src/temp/parse_yaml.sh" >&2
  fi
  if [[ "${cache_flag}" == false ]]; then
    # rm file
    if ! rm ./src/temp/parse_yaml.sh; then
        echo "Unable to rm ./src/temp/parse_yaml.sh" >&2
    fi
  fi
}

#######################################
# Check $OSTYPE and defines current OS
# GLOBALS :
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
    exit;
  fi 
}

#######################################
# Check if the current user is root
# GLOBALS
#   LOCO_DIST
# Output:
#   ./src/temp/loco_conf_is_start
#######################################
utils::check_if_start(){
  # check if first start (stores $USER without sudo)
  if [ -f "./src/temp/conf_is_start" ]; then
    # program is started
    if ! rm ./src/temp/conf_is_start; then
        echo "Unable to rm ./src/temp/conf_is_start" >&2
    fi
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
#   ./src/temp/loco_conf_is_start
#   ./src/temp/loco_conf_CURRENT_USER
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
      [[ "$UID" -eq 0 ]] || exec sudo bash "$0" "$@"
    else
      if ! source ./src/temp/conf_CURRENT_USER; then
        echo "Unable to source ./src/temp/conf_CURRENT_USER" >&2
      fi
    fi
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
  readonly BOLD=$(tput bold)
  readonly NORMAL=$(tput sgr0)
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
# Define a timestamp.
#######################################
utils::timestamp(){
  date +"%Y-%m-%d_%H-%M-%S" # current time
}

#######################################
# Removes temp files.
#######################################
utils::clean_temp(){
  if ! sudo rm -r ./src/temp/*; then
    echo "Unable to remove temp files" >&2
  fi
}