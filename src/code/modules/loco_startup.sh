#!/bin/bash
#-------------------------------------------------------------------------------
# loco_startup.sh | loco.sh startup functions
#-------------------------------------------------------------------------------

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
  # check dependencies (yaml)
  loco::check_dependencies
  
  # remove temp files
  utils::clean_temp

  # set system clock
  if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
    utils::set_clock
  fi

  # print the warning message
  msg::warning

  # build and source the actions prompt file, if there is no option set
  loco::prompt_action
}