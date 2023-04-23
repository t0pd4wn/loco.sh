#!/bin/bash
#-------------------------------------------------------------------------------
# yaml.sh | yaml function file
#-------------------------------------------------------------------------------

#######################################
# Add a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#   $4 # addition type "key|raw"
#######################################
yaml::add(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  local option="${4-"key"}"
  local hasValue

  if [[ "${option}" == "key" ]]; then
    local arg="${selector}"' = ["'"${value}"'"] + '"${selector}"
    hasValue=$(yaml::contains "${yaml}" "${selector}" "${value}" )
  elif [[ "${option}" == "raw" ]]; then
    local arg="${selector}"' = "'"${value}"'" + '"${selector}"
    # set hasvalue to false for raw content
    hasValue=false
  fi

  if [[ "${hasValue}" == false ]]; then
    # tries to add value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add ${value} in ${selector} in yaml.local"
    else
      # if success, overwrite original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
        if [[ "${option}" == "raw" ]]; then
          # if "raw" is set, perform an extra clean up
          utils::remove_string_in_file " |-" "${yaml}"
          # for some reasons an extra trailing "null" appears
          utils::remove_string_in_file "null" "${yaml}"
        fi
      fi
    fi
  fi
}

#######################################
# Add a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#   $4 # addition type "key|raw"
#######################################
yaml::add_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  local option="${4-"key"}"
  local has_selector
  
  if [[ "${option}" == "key" ]]; then
    #statements
    local arg="${selector}""${value}"' += []'
  elif [[ "${option}" == "raw" ]]; then
    local arg="${selector}""${value}"' += '
  fi

  # tries to add key
  # check if key exists already
  has_selector=$(yaml::has_child_selector "${selector}""${value}" "${yaml}")

  if [[ "${has_selector}" == false ]]; then
    # if the key desn't exist, create one
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add key ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Change a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
yaml::change(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"' = "'"${value}"'"'

  # check if value exist
  local has_value=$(yaml::contains "${yaml}" "${selector}" "${value}" )

  if "${has_value}"; then
    # value already exist
    :
  else
      # tries to add value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      _error "Unable to yq add ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        _cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Return a boolean if value is found
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
yaml::contains(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"

  local yaml_value=$(yaml::yq_child "${selector}" "${yaml}")
  
  if [[ "${yaml_value}" == *"${value}"* ]]; then
    echo true
  else
    echo false
  fi
}

#######################################
# Delete a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
yaml::delete(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"'.[] | select(. == "'"${value}"'")'

  # check if list value exist
  local has_value=$(yaml::contains "${yaml}" "${selector}" "${value}" )

  if "${has_value}"; then
    # tries to delete list value
    if ! cat "${yaml}" | yq 'del('"${arg}"')' > src/temp/yaml.local; then
      _error "Unable to yq delete ${selector}[${value}] in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        _cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Delete a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#######################################
yaml::delete_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  local has_selector
  
  local arg='del('"${selector}""${value}"')'

  # tries to delete key
  # check if key exists already
  has_selector=$(yaml::has_child_selector "${selector}""${value}" "${yaml}")

  if [[ "${has_selector}" == true ]]; then
    # if the key exists, delete it
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq delete key ${value} in ${selector} in ${yaml}"
    else
      # if succeeds, overwrites original yaml
      # condition used to ensure yaml.local is written by yq
      if [[ -f src/temp/yaml.local ]]; then
        cat src/temp/yaml.local > "${yaml}"
      fi
    fi
  fi
}

#######################################
# Execute commands from a yaml array
# Arguments:
#   $1 # a yaml file
#   $2 # a yaml selector
#######################################
yaml::execute(){
  local path="${1-}"
  local function="${2-}"
  local function_body

  # get function body
  function_body=$(yaml::get "${path}" "${function}.[]")

  # make an array from commands
  IFS=$'\n' read -r -d '' -a commands <<< "${function_body}"

  for command in "${commands[@]}"; do
    cmd::execute "${command}"
  done
}

#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
yaml::get(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}"
  local value

  value=$(yaml::yq "${yaml}" "${selector}")

  if [[ "${value}" == "" ]] || [[ "${value}" == "null" ]]; then
    return 1
  else
    _echo "${value}"
  fi
}

#######################################
# Return yaml keys (deprecated?)
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # an optional yaml file path
#######################################
yaml::get_keys(){
  local var="${1-}"
  local path="${2:-"${PROFILE_YAML}"}"

  if [[ ! -f "${path}" ]]; then
    msg::debug "${EMOJI_STOP} No " "YAML file" " found"
  else
    if ! cat "${path}" | yq "${var}" | grep -v '^ .*' | sed 's/:.*$//'; then
      _error "Unable to yq ${var} in ${path}"
    fi
  fi
}

#######################################
# Return yaml child values
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # a yaml file path
#######################################
yaml::get_child_values(){
  local var="${1-}" 
  local path="${2:-"${PROFILE_YAML}"}"
  local value

  # if file doesn't exist
  if [[ ! -f "${path}" ]]; then
    value=""
  
  # if a .yaml file is found
  else
    value=$(yaml::yq_child "${var}" "${path}")
  fi

  # sends back the value
  _echo "${value}"
}

#######################################
# Check if a child selector is present in yaml
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
yaml::has_child_selector(){ 
  local selector="${1-}" 
  local yaml="${2-}"
  
  # local child_selector=$(_echo "${selector}" | grep -oE "[^.]+$")
  local child_selector=$(_echo "${selector}" | rev | cut -d. -f1 | rev)
  local parent_selector="${selector%."${child_selector}"}"
  
  # in the case where an array is asked
  if [[ "${child_selector}" == "[]" ]]; then
    child_selector=$(_echo "${selector}" | rev | cut -d. -f2 | rev)
    parent_selector="${selector%."${child_selector}.[]"}"
  fi
  
  local has_selector=""${parent_selector}" | has(\""${child_selector}"\")"
  local selector_exist=$(cat "${yaml}" | yq "${has_selector}") 

  if [[ "${selector_exist}" == false ]]; then
    # selector doesn't exist
    echo false
  elif [[ "${selector_exist}" == true ]]; then
    # selector does exist
    echo true
  fi
}

#######################################
# Merge two yaml selectors
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.pathA"
#   $3 # a yaml selector ".variable.pathB"
#   $4 # merge type "classic|array"
#######################################
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

#######################################
# Return yaml values, no child selector check
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
yaml::yq(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}" 

  # check if selector exist in file
  # yaml::has_selector "${selector}" "${yaml}"
    # if yes, tries to recover value
  if ! cat "${yaml}" | yq "${selector}"; then
    echo "Unable to yq ${selector} in ${yaml}"
  fi
}

#######################################
# Return yaml values
# todo : precise implementation in regards to
# utils::yq_light so child selector check is more transparent
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
yaml::yq_child(){
  # local options="${1-}"
  local selector="${1-}" 
  local yaml="${2-}"
  local has_selector 

  # check if selector exist in file
  has_child_selector=$(yaml::has_child_selector "${selector}" "${yaml}")

  # check if selector exists
  if [[ "${has_child_selector}" == false ]]; then
    # if not, propagates a 1 exit code
    return 1
  else
    # if yes, tries to recover value
    yaml::yq "${yaml}" "${selector}"
  fi
}