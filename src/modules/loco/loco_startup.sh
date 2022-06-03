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
  # remove temp files
  utils::clean_temp

  # set system clock
  utils::set_clock

  # externally source the yaml parser 
  # https://github.com/mrbaseman/parse_yaml
  utils::yaml_source_parser

  # print the warning message
  msg::warning

  # build and source the actions prompt file, if there is no option set
  loco::prompt_action
}