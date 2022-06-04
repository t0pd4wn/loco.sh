#!/bin/bash
#-------------------------------------------------------------------------------
# loco_meta.sh | loco.sh meta functions
#-------------------------------------------------------------------------------

#######################################
# apply the defined cmd over the package
# GLOBALS:
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::meta_action(){
  local local_package_action_cmd
  # if there isn't a specific command, build one
  if [[ -z "${PACKAGE_ACTION_CMD-}" ]]; then 
    local_package_action_cmd="${PACKAGE_MANAGER} ${PACKAGE_ACTION} ${PACKAGE}"
    msg::debug "${local_package_action_cmd}"
    eval "${local_package_action_cmd}"
  # if there is a specific command, execute it
  else
    eval "${PACKAGE_ACTION_CMD}"
  fi
}

#######################################
# meta package: prepare package
# GLOBALS:
#   PACKAGE_MANAGER
#   PACKAGE_MANAGER_TEST_CMD
#   PACKAGE_ACTION
#   PACKAGE_ACTION_CMD
#   PACKAGE
#   ACTION
#######################################
loco::meta_package(){
  msg::debug "metaPackage ..."
  msg::debug ${PACKAGE_MANAGER-}
  msg::debug ${PACKAGE_MANAGER_TEST_CMD-}
  msg::debug ${PACKAGE_ACTION-}
  msg::debug ${PACKAGE_ACTION_CMD-}
  msg::debug ${PACKAGE-}
  local local_package_test_cmd

  #if no action is defined default to "${ACTION}"
  if [[ -z "${PACKAGE_ACTION-}" ]]; then
    msg::debug "No package action"
    PACKAGE_ACTION="${ACTION-}"
    msg::debug $PACKAGE_ACTION
  fi

  #check for test command options
  if [[ -z "${PACKAGE_TEST_CMD-}" ]]; then
      msg::debug "No local test cmd"
    if [[ -z ${PACKAGE_MANAGER_TEST_CMD-} ]]; then 
      msg::debug "No packager test cmd"
      # using the default testing command
      local_package_test_cmd='command -v $PACKAGE'
      msg::debug $local_package_test_cmd
    else
      #if $PACKAGE_MANAGER_TEST_CMD was populated, populate $local_package_test_cmd
      eval local_package_test_cmd=\$${PACKAGE_MANAGER_TEST_CMD}
      msg::debug "${local_package_test_cmd}"
    fi
  else
    #if $PACKAGE_TEST_CMD was populated, populate $local_package_test_cmd
    local_package_test_cmd="${PACKAGE_TEST_CMD}"
    msg::debug "${local_package_test_cmd}"
  fi

  # check for package status (installed/uninstalled) and act accordingly
  if eval "${local_package_test_cmd}" > /dev/null 2>&1; then
    msg::debug "${local_package_test_cmd}"
    msg::print "" "${PACKAGE_MANAGER-} ${PACKAGE-}" " is installed."
    # remove package
    if [[ "${ACTION-}" == "remove" ]]; then
      msg::say "Removing " "${PACKAGE_MANAGER} ${PACKAGE}"
      loco::meta_action
    fi
  else
    msg::print "" "${PACKAGE-}" " is not installed."
    # install package
    if [[ "${ACTION-}" == "install" ]]; then
      msg::say "Installing " "${PACKAGE_MANAGER} ${PACKAGE}"
      loco::meta_action
    fi
  fi
  # clear global variables
  PACKAGE_TEST_CMD=""
  PACKAGE_ACTION_CMD=""
  PACKAGE_MANAGER_TEST_CMD=""
}

#######################################
# meta package manager: prepare package manager
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # defines the packages type (OS specific or not)
# Output:
#   Writes the bash variables file from yaml 
#######################################
loco::meta_package_manager(){
  msg::debug "meta_package_manager ..."
  # assign the $1 package managers
  # local packagers="packages_"$1
  local packagers
  local packages
  declare -a packagers_array
  declare -a packages_array
  packagers=$(utils::yaml_get_keys ".packages.${1-}")

  # check if packagers are declared
  if [[ -z "${packagers}" ]]; then
    msg::print "No " "$1" " package managers found"
  else
    # begin to assign values recursively from descriptors
    packagers_array=($packagers)
    msg::debug "${packagers}"

    for i in "${packagers_array[@]}"; do
      msg::debug "${i}"
      # prepare variables from package manager descriptor
      PACKAGE_ACTION="${ACTION}"

      local packager_path="./src/descriptors/${i}.sh"
      # check for descriptor file
      if [[ ! -f  "${packager_path}" ]]; then
        msg::print "No " "$1" " package manager descriptor found"
      
      # if there is a descriptor file
      else
        utils::source "${packager_path}"

        # expand variable value 
        PACKAGE_ACTION=${!PACKAGE_ACTION}   
        # update the package manager
        ${PACKAGE_MANAGER} ${update}

        # parse yaml to get packages names
        local packages_selector=".packages."${1}"."${i}".[]"
        packages=$(utils::yaml_get_values "${packages_selector}")
        msg::debug "${packages}"

        packages_array=($packages)

        # send packages names to metaPackage
        for i in "${packages_array[@]}"; do
          PACKAGE="${i}"
          loco::meta_package "${PACKAGE}" "${PACKAGE_MANAGER_TEST_CMD}" ;
        done
      fi
    done
  fi
}