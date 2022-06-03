#!/bin/bash
#-------------------------------------------------------------------------------
# msg.sh | Messages functions
#-------------------------------------------------------------------------------

#######################################
# Print a debug message
# EMBEDDED VARIABLES
#   FUNCNAME[1] # parent function name
#   BASH_LINENO[0] # Function call line number
# GLOBALS:
#   VERBOSE
# Arguments:
#   $@ # a message, a variable...
#######################################
msg::debug(){
  if [[ "${VERBOSE}" == true ]]; then
    local b=$(tput bold)
    local n=$(tput sgr0)
    declare -a message
    message=("${b}""...debug : ""${n}")
    message+=("Function: " "${b}""${FUNCNAME[1]}""${n}")
    message+=("Line: ""${b}""${BASH_LINENO[0]}""${n}")
    message+=("Message: ""${b}""$@""${n}")
    utils::echo ${message[@]}
  fi
}

#######################################
# Play recorded messages
# GLOBALS:
#   MSG_ARRAY # an array of messages
#######################################
msg::play(){
  for i in "${MSG_ARRAY[@]}"; do msg::say "$i"; done
  MSG_ARRAY=()
  MSG_INDEX=0
}

#######################################
# Print a templated message
# Arguments:
#   $1, $2, $3 # "This" "is a" "message"
#######################################
msg::print(){
  local b=$(tput bold)
  local n=$(tput sgr0)
  utils::echo "${n}"${1-}"${b}"${2-}"${n}"${3-}
}

#######################################
# Print a prompt message
# GLOBALS
#   USER_ANSWER
#   LOCO_YES
# Arguments:
#   $1, $2, $3 # "This" "is a" "message"
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
# Record messages
# GLOBALS:
#   MSG_ARRAY # an array of messages
#   MSG_INDEX # array index
# Arguments:
#   $1 # "This is a message"
#######################################
msg::record(){
  MSG_INDEX+=1;
  # todo : implement as +=
  MSG_ARRAY[MSG_INDEX]="${1-}";
}

#######################################
# Print a templated message with the LOCO logo
# Arguments:
#   $1, $2, $3 # "This" "is a" "message"
#######################################
msg::say(){
  local start_text="${EMOJI_LOGO} ${1-}"
  msg::print "${start_text}" "${2-}" "${3-}"
}

#######################################
# Print the start message
# GLOBALS:
#   EMOJI_LOGO
#   VERSION
#   CURRENT_USER
#######################################
msg::start(){
  msg::print "................................................................"
  msg::print "................................................................"
  msg::print "...................." "Welcome to loco.sh ${EMOJI_LOGO} ${VERSION}" "..................."
  CURRENT_USER=$USER
}

#######################################
# Print the warning message
# GLOBALS:
#   EMOJI_STOP
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
# GLOBALS:
#   VERBOSE
#   EMOJI_LOGO
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
  # print exit function message(s)
  msg::play
  msg::print "................................................................"
  msg::print "................................................................"
}