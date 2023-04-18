#!/bin/bash
#-------------------------------------------------------------------------------
# loco_custom_functions.sh | loco.sh custom functions
#-------------------------------------------------------------------------------

#######################################
# Prepare custom functions execution
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
    local step="${1-}"
    if [[ "${ACTION}" == "update" ]]; then
      #if action is "update", then use the "install" custom functions
      local generic_function="install_${step}"
    else
      # else call dynamically
      local generic_function="${ACTION}_${step}"
    fi
    local os_specific_function="${ACTION}_${LOCO_OSTYPE}_${step}"
    loco::custom_function "${generic_function}"
    loco::custom_function "${os_specific_function}"
  else
    msg::debug "No custom.sh file found." 
  fi
}

#######################################
# Execute custom functions
# Arguments:
#   $1 # a function name
#######################################
loco::custom_function(){
  local custom_function=${1-}
  if [[ $(type -t "${custom_function}") == function ]]; then
    "${custom_function}"
  else
    msg::debug "No "${custom_function}" function found."
  fi
}

#######################################
# Execute custom entry functions
# GLOBALS:
#   PROFILE
#######################################
loco::custom_entry(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " entry custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "entry"
  done

  PROFILE="${profile_backup}"
}

#######################################
# Execute custom exit functions
# GLOBALS:
#   PROFILE
#######################################
loco::custom_exit(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " exit custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "exit"
  done

  PROFILE="${profile_backup}"
}

#######################################
# Execute custom last functions
# GLOBALS:
#   PROFILE
#######################################
loco::custom_last(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::print "Sourcing " "${PROFILE}" " last custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "last"
  done

  PROFILE="${profile_backup}"
}

#######################################
# Source the custom functions file
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
#######################################
loco::custom_source(){
  utils::source ./"${PROFILES_DIR}"/"${PROFILE}"/custom.sh
  if [ $? -ne 0 ]; then
    msg::print "Can not source custom.sh file."
  fi
}

#######################################
# Merge custom functions
# Arguments:
#   $1 # a custom file to be merged from (A)
#   $2 # a custom file to be merged with (B)
#   $3 # a custom file to keep the result
#######################################
loco::custom_merge(){
  local custom_from="${1-}"
  local custom_to="${2-}"
  local prev
  local new
  local is_same
  declare -a new_functions
  declare -a prev_functions

  # list functions from both files
  new_functions=($(utils::list_bash_functions "${custom_from}"))
  prev_functions=($(utils::list_bash_functions "${custom_to}"))


  for function in "${new_functions[@]}"; do

    if [[  "${prev_functions[*]}" =~ "${function}"  ]]; then
      # function exists in file
      new=$(utils::dump_bash_function "${function}" "${custom_from}")
      prev=$(utils::dump_bash_function "${function}" "${custom_to}")

      if [[ "${new}" == "${prev}" ]]; then
        # functions are identical
        utils::echo "${function}(){\n${prev}\n}\n" >> ./src/temp/custom.tmp
      else
        # functions are different
        prev="${prev}\n${new}"
        utils::echo "${function}(){\n${prev}\n}\n" >> ./src/temp/custom.tmp
      fi

      # remove function name from prev array
      "${prev_functions[@]/$function}"

    else
      # function doesn't exist
      new=$(utils::dump_bash_function "${function}" "${custom_from}")
      utils::echo "${function}(){\n${new}\n}\n" >> ./src/temp/custom.tmp
    fi
  done

  # dump remaining previous functions in temp file
  for function in "${prev_functions[@]}"; do
      prev=$(utils::dump_bash_function "${function}" "${custom_to}")
      utils::echo "${function}(){\n${prev}\n}\n" >> ./src/temp/custom.tmp
  done

  # replace dest file with cleaned temp one
  utils::remove "${custom_to}"
  utils::replace_string_in_file '";' '"' ./src/temp/custom.tmp
  utils::replace_string_in_file 'fi;' 'fi' ./src/temp/custom.tmp
  utils::cp ./src/temp/custom.tmp "${custom_to}"
}