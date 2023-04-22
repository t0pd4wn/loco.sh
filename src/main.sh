#!/bin/bash
#-------------------------------------------------------------------------------
# main.sh | main function file
#-------------------------------------------------------------------------------

set -eu

# source core modules
# source the utils module
if ! source ./src/code/modules/core/base.sh; then
  echo "Can not source ./src/code/base.sh" >&2
  exit 1
fi

# source other core modules
_source ./src/code/modules/core/cli.sh
_source ./src/code/modules/core/cmd.sh
_source ./src/code/modules/core/globals.sh
_source ./src/code/modules/core/msg.sh
_source ./src/code/modules/core/prompt.sh
_source ./src/code/modules/core/utils.sh
_source ./src/code/modules/core/yaml.sh

# source loco modules
_source ./src/code/modules/loco_background.sh
_source ./src/code/modules/loco_custom_functions.sh 
_source ./src/code/modules/loco_dotfiles.sh
_source ./src/code/modules/loco_fonts.sh
_source ./src/code/modules/loco_globals.sh
_source ./src/code/modules/loco_multi_profiles.sh
_source ./src/code/modules/loco_overlay.sh
_source ./src/code/modules/loco_packages.sh
_source ./src/code/modules/loco_prompts.sh
_source ./src/code/modules/loco_startup.sh
_source ./src/code/modules/loco_terminal.sh 
_source ./src/code/modules/loco_various.sh
_source ./src/code/modules/loco_watermark.sh
_source ./src/code/modules/loco_yaml.sh

#######################################
# main
# GLOBALS:
#   ACTION
#   CONFIG_PATH
# Arguments:
#   $@ # script options
#######################################
main(){
  # source the globals from loco::check_os
  _source "./src/temp/conf_OS_GLOBALS"

  # set globals
  # core ones
  globals::set
  # loco ones
  loco::GLOBALS_set

  # set options, build and source the cli file
  cli::set_options
  cli::build
  cli::call "${@-}" 

  # load default or user conf
  _source "${CONFIG_PATH}"  

  # lock globals
  loco::GLOBALS_lock 

  # init debug message
  msg::debug "Verbose mode" 

  # check if first start, else display start messsage
  loco::check_if_start 

  # check if first root, otherwise ask password and restart
  loco::check_if_root "${@-}"

  # launch startup checks and utils
  loco::startup "${@-}"

  # source main action script
  _source ./src/code/actions/"${ACTION}.sh"

  # display end message
  msg::end

  # display countdown
  utils::countdown "" "1"

  # trap custom last function
  if ! trap 'loco::custom_last' 0; then
    _error "Can not trap loco::custom_last"
  fi

  # end script
  exit $?
}

# call the main function
main "${@-}"