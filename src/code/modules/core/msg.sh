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
  if [[ "${VERBOSE-}" == true ]]; then
    local b=$(tput bold)
    local n=$(tput sgr0)
    declare -a message
    message=("${b}""...debug :""${n}")
    message+=("Function: " "${b}""${FUNCNAME[1]}""${n}")
    message+=("Line: ""${b}""${BASH_LINENO[0]}""${n}")
    message+=("Message: ""${b}""$@""${n}")
    echo ${message[@]}
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
# Print a centered templated message
# Arguments:
#   $1 # "This is a message"
#   $2 # an extra length option
#######################################
msg::centered(){
  local message="${1-}"
  local option="${2-}"
  # this is meant to decode encoded characters
  local message=$(echo -e $message)
  local message_length=${#message}

  # add the option extra length
  if [[ -n "${option}" ]]; then
    message_length=$(( message_length + option ))
  fi
  local cli_length=$(msg::get_length)
  local extra_space=0
  local separator
  local separator_length=$(((cli_length + extra_space - message_length) / 2 ))
  local total=$((separator_length*2 + message_length))

  for (( i = 0; i < ${separator_length}; i++ )); do
    separator+="."
  done

  local separatorB
  separatorB=${separator}

  # if message is odd, add en extra separator character
  if [ $((message_length%2)) -eq 0 ]; then
    msg::debug "Message length is even."
  else
    msg::debug "Message length is odd."
    separatorB+="."
  fi

  msg::print "${separator}" "${message}" "${separatorB}"
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
# Print an author message
#######################################
msg::authors(){
  msg::centered ""
  msg::centered "Author : t0pd4wn"
  msg::centered ""
}

#######################################
# Print an edition date message
#######################################
msg::date(){
  msg::centered "2022"
}

#######################################
# Print an edition date message
#######################################
msg::license(){
  msg::centered "Licensed under GPL V3"
}

#######################################
# Print the start message
# GLOBALS:
#   EMOJI_LOGO
#   VERSION
#   CURRENT_USER
#######################################
msg::start(){
  msg::centered ""
  msg::centered ""
  msg::centered "Welcome to loco.sh ${EMOJI_LOGO} ${VERSION}" "1"
  msg::authors
}

#######################################
# Print the warning message
# GLOBALS:
#   EMOJI_STOP
#######################################
msg::warning(){
  msg::centered ""
  msg::centered ""
  msg::centered "${EMOJI_STOP} Modifying packages can break your system. ${EMOJI_STOP}" "2"
  msg::centered " Proceed at your own risks. "
  msg::centered ""
  msg::centered ""
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
  msg::centered ""
  msg::centered ""
  msg::centered ""
  msg::centered " Thank you for using loco.sh ${EMOJI_LOGO} ${VERSION}" "1"
  msg::centered ""
  # print license message
  msg::license
  msg::centered ""
  # print date
  msg::date
  # print exit function message(s)
  msg::play
  msg::centered ""
  msg::centered ""
}

#######################################
# Get cli length to adapt message length
#######################################
msg::get_length(){
  if ! echo -e "cols"|tput -S; then
    _error "Unable to get the terminal columns number."
  fi
}