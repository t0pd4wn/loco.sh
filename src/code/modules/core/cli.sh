#!/bin/bash
#-------------------------------------------------------------------------------
# cli.sh | cli.sh functions
#-------------------------------------------------------------------------------

#######################################
# Build cli file
# note: echo is preferred to _echo here,
# because it doesn't require su rights
# GLOBALS:
#   CLI_OPT_PARAMETERS
#   CLI_OPT_DESCRIPTIONS
#   HELP_TEXT
# Output:
#   ./src/temp/cli.sh
#######################################
cli::build(){
  local cli_file=./src/temp/cli.sh
  local joined_parameters
  local joined_descriptions
  # build file
  joined_parameters=$(IFS=; echo "${CLI_OPT_PARAMETERS[*]}");
  joined_descriptions=$(IFS=; echo "${CLI_OPT_DESCRIPTIONS[*]}");
  # create temp folder
  mkdir -p "./src/temp"
  _echo "while getopts ${joined_parameters} flag" > "${cli_file}"
  _echo "do" >> "${cli_file}"
  _echo "case "'"${flag}"'" in" >> "${cli_file}"
  _echo "${joined_descriptions}" >> "${cli_file}"              
  _echo "esac" >> "${cli_file}"
  _echo "done" >> "${cli_file}"
}

#######################################
# Call the cli
# Arguments:
#   $@ // cli options
#######################################
cli::call(){
  local cli_path=./src/temp/cli.sh
  local cli_args="${@-}"
  _source "${cli_path}" "${cli_args}"
}

#######################################
# Set cli options and GLOBALS
# GLOBALS:
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
# GLOBALS:
#   HELP_TEXT
#######################################
cli::print_help(){
  local joined_help_text
  joined_help_text=$(IFS=; echo "${HELP_TEXT[*]}");
  _echo "${joined_help_text}"
  _echo "loco.sh ${EMOJI_LOGO}"
}

#######################################
# Print the version number.
# Globals:
#   EMOJI_LOGO
#   VERSION
#######################################
cli::print_version(){
  _echo "loco.sh ${EMOJI_LOGO} version ${VERSION}"
}

#######################################
# Register cli options
# GLOBALS:
#   ACTION
#   BACKGROUND
#   BACKGROUND_URL
#   PROFILE
#   CURRENT_USER
#   PROFILES_DIR
#   INSTANCES_DIR
#   CONFIG_PATH
#   THEME
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

  declare -A theme_opt_array
  theme_opt_array=(
    [GLOBAL]="THEME"
    [option]="t:"
    [description]="Define the selected theme"
    [default]=""
    [CMD]=""
  )
  cli::define_option theme_opt_array

  declare -A background_opt_array
  background_opt_array=(
    [GLOBAL]="BACKGROUND"
    [option]="b:"
    [description]="Define the selected background"
    [default]=""
    [CMD]=""
  )
  cli::define_option background_opt_array

  declare -A background_url_opt_array
  background_url_opt_array=(
    [GLOBAL]="BACKGROUND_URL"
    [option]="B:"
    [description]="Define the background url"
    [default]=""
    [CMD]=""
  )
  cli::define_option background_url_opt_array

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
    [default]="0.7"
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

  declare -A overlay_flag_array
  overlay_flag_array=(
    [GLOBAL]="OVERLAY"
    [option]="o"
    [description]="Activate the overlay option"
    [default]=false
    [CMD]="OVERLAY=true"
  )
  cli::define_option overlay_flag_array

  declare -A overlay_option_array
  overlay_option_array=(
    [GLOBAL]="OVERLAY_PATH"
    [option]="O:"
    [description]="Define an overlay path"
    [default]=""
    [CMD]=""
  )
  cli::define_option overlay_option_array

}