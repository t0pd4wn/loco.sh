#!/bin/bash
#-------------------------------------------------------------------------------
# globals.sh | globals variables management
#-------------------------------------------------------------------------------

#######################################
# Set GLOBALS
#######################################
globals::set(){
  # readonly ?
  IS_ROOT=$(id -u)
  # used in cli
  declare -ga CLI_OPT_PARAMETERS
  declare -ga CLI_OPT_DESCRIPTIONS
  declare -ga HELP_TEXT
  # used in messages
  declare -ga MSG_ARRAY
  MSG_INDEX=0
  declare -g TERM_STORED_LENGTH
  # used in prompts
  declare -g USER_ANSWER
}

#######################################
# Lock GLOBALS
#######################################
# globals::lock(){
# }