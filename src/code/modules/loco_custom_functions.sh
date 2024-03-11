#!/bin/bash
#-------------------------------------------------------------------------------
# loco_custom_functions.sh | loco.sh custom functions
#-------------------------------------------------------------------------------

########################################
# Prepare custom functions execution
# GLOBALS:
#   ACTION
#   LOCO_OSTYPE
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # "entry" or "exit"
########################################
loco::custom_action(){
  local step="${1-}"
  local custom_function_path="./"${PROFILES_DIR}"/"${PROFILE}"/custom.sh"
  local custom_function_yaml="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"

  if [[ -f "${custom_function_path}" || -f "${custom_function_yaml}" ]]; then
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
    msg::debug "No custom.sh or yaml file found." 
  fi
}

########################################
# Execute custom functions
# Arguments:
#   $1 # a function name
########################################
loco::custom_function(){
  local custom_function=${1-}

  if [[ -n $(declare -F "${custom_function}") ]]; then
    if [[ $(type "${custom_function}")  == *"function"* ]]; then
      "${custom_function}"
    else
      msg::debug "No "${custom_function}" function found in custom.sh."
    fi
  fi

  local has_selector
  local selector=".custom_functions.${custom_function}"
  local yaml_path="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"

  has_selector=$(yaml::contains "${yaml_path}" "${selector}")

  if [[ ${has_selector} == true ]]; then
    yaml::execute "${yaml_path}" "${selector}"
  else 
    msg::debug "No "${custom_function}" function found in profile.yaml."
  fi
}

########################################
# Execute custom entry functions
# GLOBALS:
#   PROFILE
########################################
loco::custom_entry(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::say "Sourcing " "${PROFILE}" " entry custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "entry"
  done

  PROFILE="${profile_backup}"
}

########################################
# Execute custom exit functions
# GLOBALS:
#   PROFILE
########################################
loco::custom_exit(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::say "Sourcing " "${PROFILE}" " exit custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "exit"
  done

  PROFILE="${profile_backup}"
}

########################################
# Execute custom last functions
# GLOBALS:
#   PROFILE
########################################
loco::custom_last(){
  local profile_backup="${PROFILE}"
  local profile_array=(${PROFILE})
  local profile_array_length="${#profile_array[@]}"

  # source custom.sh
  msg::say "Sourcing " "${PROFILE}" " last custom functions."

  # reverse the array sequence so to execute commands recursively
  for (( i = "${profile_array_length}"-1; i >= 0; i-- )); do
    PROFILE="${profile_array[$i]}"
    loco::custom_source
    loco::custom_action "last"
  done

  PROFILE="${profile_backup}"
}

########################################
# Source the custom functions file
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
########################################
loco::custom_source(){
  local path="./${PROFILES_DIR}/${PROFILE}/custom.sh"
  
  if [[ -f "${path}" ]]; then
    _source "${path}"
    if [ $? -ne 0 ]; then
      msg::print "Can not source custom.sh file."
    fi
  fi
}

########################################
# Merge custom functions
# Arguments:
#   $1 # a custom file to be merged from (A)
#   $2 # a custom file to be merged with (B)
#   $3 # a custom file to keep the result
########################################
loco::custom_merge(){
  local custom_from="${1-}"
  local custom_to="${2-}"
  local custom_file="./src/temp/custom.tmp"
  local prev
  local new
  local is_same
  declare -a new_functions
  declare -a prev_functions

  # list functions from both files
  new_functions=($(utils::list_bash_functions "${custom_from}"))
  prev_functions=($(utils::list_bash_functions "${custom_to}"))

  # remove temp file before text manipulations
  if [[ -f "${custom_file}" ]]; then
    utils::remove "${custom_file}"
  fi

  for function in "${new_functions[@]}"; do
    if [[ "${prev_functions[*]}" =~ "${function}" ]]; then
      # function exists in file
      new=$(utils::dump_bash_function "${function}" "${custom_from}")
      prev=$(utils::dump_bash_function "${function}" "${custom_to}")

      if [[ "${new}" == "${prev}" ]]; then
        # functions are identical
        # dump to temp file
        echo $"${function}(){" >> "${custom_file}"
        # regular echo, because custom functions may hold escaped characters
        echo "${new}" >> "${custom_file}"
        echo "}" >> "${custom_file}"
      else

        # dump to temp file
        echo $"${function}(){" >> "${custom_file}"
        # regular echo, because custom functions may hold escaped characters
        echo "${prev}" >> "${custom_file}"
        echo "${new}" >> "${custom_file}"
        echo "}" >> "${custom_file}"
      fi
    else
      # function doesn't exist
      new=$(utils::dump_bash_function "${function}" "${custom_from}")

      # dump to temp file
      echo $"${function}(){" >> "${custom_file}"
      # regular echo, because custom functions may hold escaped characters
      echo "${new}" >> "${custom_file}"
      echo "}" >> "${custom_file}"
    fi
  done

  # dump remaining previous functions in temp file
  for function in "${prev_functions[@]}"; do
    # check if function has been processed already
    if [[ "${new_functions[*]}" =~ "${function}" ]]; then
      msg::debug "Function exists already"
    else
      # if not, copy the function
      prev=$(utils::dump_bash_function "${function}" "${custom_to}")

      # dump to temp file
      echo $"${function}(){" >> ./src/temp/custom.tmp
      # regular echo, because custom functions may hold escaped characters
      echo "${prev}" >> ./src/temp/custom.tmp
      echo "}" >> ./src/temp/custom.tmp
    fi
  done

  # replace destination file with cleaned temporary one
  utils::remove "${custom_to}"
  utils::replace_string_in_file '";' '"' ./src/temp/custom.tmp
  utils::replace_string_in_file 'fi;' 'fi' ./src/temp/custom.tmp
  _cp ./src/temp/custom.tmp "${custom_to}"
}

#######################################
# Add instructions to "/.loco_startup" "session_start"
# Arguments:
#   $1 # a command to be written
########################################
loco::custom_add_to_start(){
  local instruction="${@-}"
  local file_path="${INSTANCE_PATH}/dotfiles/.loco_startup"
  local start_function="session_start"
  local start_function_body

  start_function_body=$(utils::dump_bash_function "${start_function}" "${file_path}")

  # remove previous function block
  utils::remove_textblock_in_file "${file_path}" "#session_start##########################" "}" 

  # write the function anew
  _echo "\n#session_start##########################" >> "${file_path}"
  _echo "# Called first time terminal is opened" >> "${file_path}"
  _echo "# !if a VPN identifier is set properly in 'is_started'!" >> "${file_path}"
  _echo "# note: this function can be manipulated by loco.sh" >> "${file_path}"
  _echo "########################################" >> "${file_path}"
  _echo $"session_start(){" >> "${file_path}"
  # regular echo as this block can contain escaped characters
  echo "${start_function_body}" >> "${file_path}"
  echo "    ${instruction}" >> "${file_path}"
  _echo $"}" >> "${file_path}"
}

#######################################
# Add instructions to "/.loco_startup" "session_start"
# Arguments:
#   $1 # a command to be written
########################################
loco::custom_add_to_shell(){
  local instruction="${@-}"
  local file_path="${INSTANCE_PATH}/dotfiles/.loco_startup"
  local function="shell_start"
  local function_body

  function_body=$(utils::dump_bash_function "${function}" "${file_path}")

  # remove previous function block
  utils::remove_textblock_in_file "${file_path}" "#session_start##########################" "}" 

  # write the function anew
  _echo "\n#session_start##########################" >> "${file_path}"
  _echo "# Called first time terminal is opened" >> "${file_path}"
  _echo "# !if a VPN identifier is set properly in 'is_started'!" >> "${file_path}"
  _echo "# note: this function can be manipulated by loco.sh" >> "${file_path}"
  _echo "########################################" >> "${file_path}"
  _echo $"shell_start(){" >> "${file_path}"
  # regular echo as this block can contain escaped characters
  echo "${function_body}" >> "${file_path}"
  echo "    ${instruction}" >> "${file_path}"
  _echo $"}" >> "${file_path}"
}

#######################################
# Add instruction to a function in a file
# Arguments:
#   $1 # a/file/path
#   $2 # a function name in the file
#   $1 # a command to be written
########################################
loco::custom_add_to(){
  local file_path="${1-}"
  local function="${2-}"
  local instruction="${3-}"
  local function_body

  function_body=$(utils::dump_bash_function "${function}" "${file_path}")

  # remove previous function block
  utils::remove_textblock_in_file "${file_path}" "###${function}###" "}" 

  # write the function anew
  _echo "\n###${function}###" >> "${file_path}"
  _echo "# Called when ${function}" >> "${file_path}"
  _echo "# note: this function can be manipulated by loco.sh" >> "${file_path}"
  _echo "# see original dotfiles for comments" >> "${file_path}"
  _echo "########################################" >> "${file_path}"
  _echo $"${function}(){" >> "${file_path}"
  # regular echo as this block can contain escaped characters
  echo "${function_body}" >> "${file_path}"
  echo "    ${instruction}" >> "${file_path}"
  _echo $"}" >> "${file_path}"
}