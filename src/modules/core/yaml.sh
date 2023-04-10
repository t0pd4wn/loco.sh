#######################################
# Return yaml keys
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # an optional yaml file path
#######################################
utils::yaml_get_keys(){
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
# Return yaml values (deprecated?)
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml variable ".variable.path"
#   $2 # a yaml file path
#######################################
utils::profile_get_values(){
  local var="${1-}" 
  local path="${2:-"${PROFILE_YAML}"}"
  local value

  # if file doesn't exist
  if [[ ! -f "${path}" ]]; then
    value=""
  
  # if a .yaml file is found
  else
    value=$(utils::yq "${var}" "${path}")
  fi

  # sends back the value
  utils::echo "${value}"
}


#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
utils::yq_get(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}" 
  local value

  value=$(utils::yq2 "${yaml}" "${selector}")

  if [[ "${value}" == "" ]] || [[ "${value}" == "null" ]]; then
    return 1
  else
    utils::echo "${value}"
  fi
}


#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#######################################
utils::yq2(){
  # local options="${1-}"
  local yaml="${1-}"
  local selector="${2-}" 

  # check if selector exist in file
  # utils::yq_has_selector "${selector}" "${yaml}"
    # if yes, tries to recover value
  if ! cat "${yaml}" | yq "${selector}"; then
    echo "Unable to yq ${selector} in ${yaml}"
  fi
}


#######################################
# Return yaml values
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
utils::yq(){
  # local options="${1-}"
  local selector="${1-}" 
  local yaml="${2-}"

  # check if selector exist in file
  utils::yq_has_selector "${selector}" "${yaml}"

  # check if error code is 0
  if (( $? != 0 )); then
    # if not, propagates a 1 exit code
    return 1
  else
    # if yes, tries to recover value
    if ! cat "${yaml}" | yq "${selector}"; then
      echo "Unable to yq ${selector} in ${yaml}"
    fi
  fi
}

#######################################
# Check if a yaml selector is present in file
# Globals:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # a yaml selector ".variable.path"
#   $2 # a yaml file path
#######################################
utils::yq_has_selector(){ 
  local selector="${1-}" 
  local yaml="${2-}"
  # local child_selector=$(utils::echo "${selector}" | grep -oE "[^.]+$")
  local child_selector=$(utils::echo "${selector}" | rev | cut -d. -f1 | rev)
  local parent_selector="${selector%."${child_selector}"}"
  
  # in the case where an array is asked
  if [[ "${child_selector}" == "[]" ]]; then
    child_selector=$(utils::echo "${selector}" | rev | cut -d. -f2 | rev)
    parent_selector="${selector%."${child_selector}.[]"}"
  fi
  
  local has_selector=""${parent_selector}" | has(\""${child_selector}"\")"
  local selector_exist=$(cat "${yaml}" | yq "${has_selector}") 

  if [[ "${selector_exist}" == false ]]; then
    # selector doesn't exist
    return 1
  elif [[ "${selector_exist}" == true ]]; then
    # selector does exist
    return 0
  fi
}

#######################################
# Return a boolean if value is found
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_contains(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"

  local yaml_value=$(utils::yq "${selector}" "${yaml}")
  
  if [[ "${yaml_value}" == *"${value}"* ]]; then
    echo true
  else
    echo false
  fi
}

#######################################
# Add a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_add(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"' = ["'"${value}"'"] + '"${selector}"

  # check if list value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # value already exist
    :
  else
      # tries to add list value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add ${value} in ${selector} in ${yaml}"
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
# Delete a yaml value
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".variable.path"
#   $3 # a yaml value
#######################################
utils::yq_delete(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"'.[] | select(. == "'"${value}"'")'

  # check if list value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # tries to delete list value
    if ! cat "${yaml}" | yq 'del('"${arg}"')' > src/temp/yaml.local; then
      echo "Unable to yq delete ${selector}[${value}] in ${yaml}"
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
utils::yq_change(){
  local yaml="${1-}"
  local selector="${2-}" 
  local value="${3-}"
  
  local arg="${selector}"' = "'"${value}"'"'

  # check if value exist
  local hasValue=$(utils::yq_contains "${yaml}" "${selector}" "${value}" )

  if "${hasValue}"; then
    # value already exist
    :
  else
      # tries to add value
    if ! cat "${yaml}" | yq "${arg}" > src/temp/yaml.local; then
      echo "Unable to yq add ${value} in ${selector} in ${yaml}"
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
# Add a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#######################################
utils::yq_add_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  
  local arg="${selector}""${value}"' += []'

  # tries to add key
  # check if key exists already
  utils::yq_has_selector "${selector}""${value}" "${yaml}"
  if (( $? != 0 )); then
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
# Delete a yaml nested key
# Arguments:
#   $1 # a yaml file path
#   $2 # a yaml selector ".parent.path"
#   $3 # a yaml value ".childpath"
#######################################
utils::yq_delete_key(){
  local yaml="${1-}"
  local selector="${2-}"
  local value="${3-}"
  
  local arg='del('"${selector}""${value}"')'

  # tries to delete key
  # check if key exists already
  utils::yq_has_selector "${selector}""${value}" "${yaml}"

  if (( $? == 0 )); then
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