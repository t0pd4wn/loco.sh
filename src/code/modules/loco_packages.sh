#!/bin/bash
#-------------------------------------------------------------------------------
# loco_meta.sh | loco.sh meta functions
#-------------------------------------------------------------------------------

#######################################
# apply the defined cmd over the package
# GLOBALS:
#   LOCO_OSTYPE
#   PACKAGE_ACTION_CMD
#   PACKAGE_MANAGER
#   PACKAGE_ACTION
#   PACKAGE
#######################################
loco::package_action(){

  # if there isn't a specific command, build one
  if [[ -z "${PACKAGE_ACTION_CMD-}" ]]; then 
    PACKAGE_ACTION_CMD="${PACKAGE_MANAGER} ${PACKAGE_ACTION} ${PACKAGE}"
    msg::debug "${PACKAGE_ACTION_CMD}"
  fi

  if [[ "${LOCO_OSTYPE}" == "macos" ]] && [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
      cmd::run_as_user "eval "${PACKAGE_ACTION_CMD}""
  else
    eval "${PACKAGE_ACTION_CMD}"
  fi

  # clear global value
  PACKAGE_ACTION_CMD=""
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
loco::package_prepare(){
  msg::debug "Package ..."
  msg::debug ${PACKAGE_MANAGER-}
  msg::debug ${PACKAGE_MANAGER_TEST_CMD-}
  msg::debug ${PACKAGE_ACTION-}
  msg::debug ${PACKAGE_ACTION_CMD-}
  msg::debug ${PACKAGE-}

  local local_package_test_cmd
  local PROFILE_YAML=/"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml

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
      loco::package_action

      # delete yaml key in /home/$USER/.loco.yml
      yaml::delete "${PROFILE_YAML}" ".packages.${LOCO_OSTYPE}.${PACKAGE_MANAGER}" "${PACKAGE}"
    fi
  else
    msg::print "" "${PACKAGE-}" " is not installed."
    # install package
    if [[ "${ACTION-}" == "install" ]] || [[ "${ACTION-}" == "update" ]]; then
      msg::say "Installing " "${PACKAGE_MANAGER} ${PACKAGE}"
      loco::package_action

      # create yaml key in /home/$USER/.loco.yml
      yaml::add "${PROFILE_YAML}" ".packages.${LOCO_OSTYPE}.${PACKAGE_MANAGER}" "${PACKAGE}"
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
loco::package_managers(){
  msg::debug "package_manager ..."
  # assign the $1 package managers
  # local packagers="packages_"$1
  local pkg_type=${1-}
  local packagers
  local packages
  declare -a packagers_array
  declare -a packages_array

  # get the packagers list from either the profile or the instance yaml
  if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
    local current_yaml="${PROFILE_YAML}"
  elif [[ "${ACTION}" == "remove" ]]; then
    local current_yaml="${INSTANCE_YAML}"
  fi
    packagers=$(yaml::get_keys ".packages.${pkg_type}" "${current_yaml}")

  # check if packagers are declared
  if [[ -z "${packagers}" ]]; then
    msg::print "No " "$1" " package managers found"
    return 0
  else

    # begin to assign values recursively from descriptors
    packagers_array=($packagers)
    msg::debug "${packagers}"
    echo "${packagers}"

    for i in "${packagers_array[@]}"; do
      msg::debug "${i}"


      # prepare variables from package manager descriptor
      if [[ "${ACTION}" == "update" ]]; then
        PACKAGE_ACTION="install"
      else 
        PACKAGE_ACTION="${ACTION}"
      fi

      local packager_path="./src/code/descriptors/${i}.sh"
      # check for descriptor file
      if [[ ! -f  "${packager_path}" ]]; then
        msg::print "No " "$1" " package manager descriptor found"
      
      # if there is a descriptor file
      else
        _source "${packager_path}"

        # add package manager to the instance yaml
        local yaml_key=".packages.${pkg_type}.${PACKAGE_MANAGER}"
        yaml::add_key "${INSTANCE_YAML}" "${yaml_key}"

        # expand variable value 
        PACKAGE_ACTION=${!PACKAGE_ACTION}
        # update the package manager
        if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
          if [[ "${PACKAGE_MANAGER}" == "brew" ]]; then
            cmd::run_as_user "${PACKAGE_MANAGER} ${update}"
          fi
        else
          ${PACKAGE_MANAGER} ${update}
        fi

        # parse yaml to get packages names
        local packages_selector=".packages."${1}"."${i}".[]"
        packages=$(yaml::get "${current_yaml}" "${packages_selector}")
        packages_array=($packages)

        # send packages names to meta_package
        for i in "${packages_array[@]}"; do
          PACKAGE="${i}"
          loco::package_prepare "${PACKAGE}" "${PACKAGE_MANAGER_TEST_CMD}" ;
        done
      fi
    done
  fi
}