#!/bin/bash
#-------------------------------------------------------------------------------
# yaml.sh | yaml function file
#-------------------------------------------------------------------------------

########################################
# Add a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#   $4 # addition type "key|raw"
########################################
yaml::add(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  local has_value

  if ! yb -af "${yaml}" -k "${selector}" -v "- ${value}"; then
    echo "Unable to yb add ${value} in ${selector} in ${yaml}"
  fi
}

########################################
# Return a boolean if value is found
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
########################################
yaml::contains(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"

  if ! yb -qf "${yaml}" -k "${selector}" -v "${value}"; then
    echo "Unable to yb -qf ${yaml} -k ${selector} -v ${value}"
  fi
}

########################################
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
########################################
yaml::get(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}"

  if ! yb -Rf "${yaml}" -k "${selector}"; then
    echo "Unable to yb -f ${yaml} ${selector}"
  fi
}

########################################
# Return yaml values as an array
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
########################################
yaml::get_array(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}"

  if ! yb -Af "${yaml}" -k "${selector}"; then
    echo "Unable to yb -f ${yaml} ${selector}"
  fi
}

# ########################################
# # Change a yaml value
# # Arguments:
# #   $1 # a yaml file path
# #   $2 # a yaml selector ".variable.path"
# #   $3 # a yaml value
# ########################################
yaml::change(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  if ! yb -cf "${yaml}" -k "${selector}" -v "${value}"; then
    echo "Can not change ${selector} with ${value} in ${yaml}."
  fi
}

########################################
# Delete a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
########################################
yaml::delete(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"

  if ! yb -rf "${yaml}" -k "${selector}" -v "${value}"; then
    echo "Can not delete ${value} in ${selector} in ${yaml}"
  fi
}

########################################
# Delete a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
########################################
yaml::delete_key(){
  local yaml="${1-}"
  local selector="${2-}"

  if ! yb -rf "${yaml}" -k "${selector}"; then
    echo "Can not delete ${selector} in ${yaml}"
  fi
}

########################################
# Execute commands from a yaml array
# Arguments:
#   $1 # a yaml file
#   $2 # a yaml selector
########################################
yaml::execute(){
  local path="${1-}"
  local function="${2-}"
  local function_body

  # get function body
  function_body=$(yaml::get_array "${path}" "${function}")

  # make an array from commands
  IFS=$'\n' read -r -d '' -a commands <<< "${function_body}"

  for command in "${commands[@]}"; do
    cmd::execute "${command}"
  done
}

########################################
# Return yaml keys
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # an optional yaml file path
########################################
yaml::get_keys(){
  local yaml="${1}"
  local selector="${2-}"
  declare -a result
  declare -a output

  result=($(yaml::get_array "${yaml}" "${selector}"))
  
  for key in "${result[@]}"; do
    if [[ "${key}" == *"_" ]]; then
      output+=("${key%%_}")
    fi
  done

  echo "${output}"
}

########################################
# Add a yaml value after a specific list value (to be reviewed)
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a specific yaml value
#   $4 # yaml value to be added
########################################
yaml::add_after(){
  local yaml="${1-}"
  local selector="${2-}"
  local target="${3-}"
  local addition="${4-}"
  declare -a yaml_list
  declare -a new_list

  yaml_list=($(yaml::get "${yaml}" "${selector}[]" "${target}" "${addition}"))

  for element in "${yaml_list[@]}"; do
    # add the previous list element to the new list
    new_list+=("${element}")
    # if the element is the targeted one, add the new value after it
    if [[ "${element}" == "${target}" ]]; then
      new_list+=("${addition}")
    fi
    # remove the element from the orginal yaml list
    yaml::delete  "${yaml}" "${selector}" "${target}"
  done

  for new_element in "${new_list[@]}"; do
    yaml::add "${yaml}" "${selector}" "${new_element}"
  done
}

########################################
# Merge two yaml selectors
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.pathA"
#   $3 # a yaml selector ".variable.pathB"
#   $4 # merge type "classic|array"
########################################
yaml::merge(){
  local yaml="${1-}"
  local selecA="${2-}" 
  local selecB="${3-}"
  local option="${4-"classic"}"
  local operator

  if [[ "${option}" == "classic" ]]; then
      operator="*"
  elif [[ "${option}" == "array-merge" ]]; then
      operator="*?n"
  elif [[ "${option}" == "array-append" ]]; then
      operator="*?+"
  fi
  
  if ! cat "${yaml}" | yq ''"${selecA}"' '"${operator}"' '"${selecB}"''; then
    _error "Unable to yq merge ${selecA} with ${selecB} in ${yaml}"
  fi
}