#!/bin/bash
#-------------------------------------------------------------------------------
# loco_dotfiles.sh | loco.sh dotfiles functions
#-------------------------------------------------------------------------------

#######################################
# Manage dotfiles installation or removal
# GLOBALS:
#   ACTION
#   CURRENT_USER
#   EMOJI_YES
#   LOCO_YES
#   LOCO_OSTYPE
#   INSTANCES_DIR
#   INSTANCES_PATH
#   PROFILES_DIR
#   PROFILE
# Arguments:
#   $1, 2, 3 # "This" "is a" "message"
#######################################
loco::dotfiles_manager(){
  local dotfiles_dir
  local dotfiles_list
  local dotfiles_yaml
  local yaml_urls
  local url_filename

  # prompt a dotfiles related y/n question
  msg::prompt "$1" "$2" "$3"
  case ${USER_ANSWER:0:1} in
  y|Y )

    if [[ "${ACTION}" == "install" ]]; then
      loco::instance_create
    fi

    # $ACTION == "install || update"
    if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" ==  "update" ]]; then
        dotfiles_dir="./"${PROFILES_DIR}"/"${PROFILE}"/dotfiles"
        dotfiles_yaml="./"${PROFILES_DIR}"/"${PROFILE}"/profile.yaml"
        yaml_urls=$(yaml::get "${dotfiles_yaml}" ".dotfiles[]")

        # if there are urls in yaml download them into "${PROFILE}"/dotfiles"
        if [[ -n "${yaml_urls}" ]]; then
            # make an array from commands
            IFS=$'\n' read -r -d '' -a urls <<< "${yaml_urls}"
            for url in "${urls[@]}"; do
              url_filename=$(utils::get_string_last "${url}" "/")
              # if the url file already exist in /dotfiles/ do nothing
              if [[ -f "${dotfiles_dir}/${url_filename}" ]]; then
                msg::say "File" "${url_filename}" " already exists."
              else
                # file does not exist, get it
                utils::get_url "${dotfiles_dir}" "${url}"
              fi
            done
        fi

        # check if there are dotfiles in $PROFILE
        if [[ -d "${dotfiles_dir}" ]]; then
        utils::list dotfiles "${dotfiles_dir}"
        loco::dotfiles_action_install "${dotfiles[@]}"
        fi
      # empty the normative list (array ?)
      # meant for multi actions (?)
      dotfiles=()
    fi

      # $ACTION == "remove"
    if [[ "${ACTION}" == "remove" ]]; then  
        dotfiles_list=$(yaml::get "${INSTANCE_YAML}" ".dotfiles.installed[]") 
        loco::dotfiles_action_remove "${dotfiles_list}"
    fi

  ;;
  * )
    msg::print "${EMOJI_NO} No, I'll stick to " "current dotfiles"
  ;;
  esac
}

#######################################
# Dotfiles install procedure
# GLOBALS:
#   CURRENT_USER
#   EMOJI_YES
#   INSTANCE_PATH
#   PROFILE_PATH
#   PROFILE
# Arguments:
#   $@ # an array of dotfiles
#######################################
loco::dotfiles_action_install(){
  declare -a dotfiles
  dotfiles=("$@")
  local current_path=$(pwd)

  msg::print "${EMOJI_YES} Yes, use " "${PROFILE}" " dotfiles"
  msg::print "Preparing your dotfiles backup"

  # create the PROFILE_PATH depending on cli option
  if [[ ${PROFILES_DIR} == "profiles" ]]; then
    # if PROFILES_DIR is the default value
    PROFILE_PATH="${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"
  else
    # if PROFILES_DIR is a custom value
    PROFILE_PATH="${PROFILES_DIR}"/"${PROFILE}"
  fi

  # backup $CURRENT_USER dotfiles and install $PROFILE ones
  for dotfile in "${dotfiles[@]}"; do
    # if "${dotfile}" already exists, backup it
    loco::dotfiles_backup "${dotfile}"
    # copy/link "${dotfile}"
    loco::dotfiles_set "${dotfile}"
  done

  # change rights to $CURRENT_USER so dotfiles are editable
  utils::chown "${CURRENT_USER}" "${INSTANCE_PATH}/dotfiles/.*"

  msg::say "${CURRENT_USER}" " dotfiles were backup'd here :"
  msg::say "${INSTANCE_PATH}/dotfiles-backup"
}

#######################################
# Dotfiles remove procedure
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
# Arguments:
#   $@ # an array of dotfiles names
#######################################
loco::dotfiles_action_remove(){
  declare -a dotfiles
  dotfiles=(${@})

  msg::print "${EMOJI_YES} Yes, remove " "${PROFILE}" " dotfiles"   
  msg::print "Restoring " "${CURRENT_USER}" " dotfiles"

  # remove $PROFILE dotfiles and restore backups
  for dotfile in "${dotfiles[@]}"; do
    loco::dotfiles_unset "${dotfile}"
  done
}

#######################################
# Backup dotfiles to $INSTANCE_PATH
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#   OS_PREFIX
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_backup(){
  local dotfile="${1-}"
  local profile_file="${INSTANCE_PATH}"/dotfiles-backup/"${dotfile}"
  local user_file=/"${OS_PREFIX}"/"${CURRENT_USER}"/"${dotfile}"

  # if the file doesn't exist
  if [ ! -f "${user_file}" ]; then
    msg::debug "${user_file}"
    msg::print "No corresponding " "${dotfile}" " file"
  else
    utils::cp "${user_file}" "${profile_file}"
    utils::remove "${user_file}"
    # add entry to instance yaml
    yaml::add "${INSTANCE_YAML}" ".dotfiles.backup" "${dotfile}"
    msg::debug "${dotfile}" " is backup'd"
  fi
}

#######################################
# Merge two dotfiles folders together
# Arguments:
#   $1 # a dotfiles path to be merged from (A)
#   $2 # a dotfiles path to be merged with (B)
#######################################
loco::dotfiles_merge(){
  local dotfiles_from="${1-}"
  local dotfiles_to="${2-}"
  local prev
  local new
  local is_same

  # list dotfiles
  utils::list "dotfiles_list_A" "${dotfiles_from}" "all"
  utils::list "dotfiles_list_B" "${dotfiles_to}" "all"

  for dotfile in "${dotfiles_list_A[@]}"; do
      prev="${dotfiles_to}/${dotfile}"
      new="${dotfiles_from}/${dotfile}"

    if [[ -f "${dotfiles_to}/${dotfile}" ]]; then
      # filenames are similar
      # compare files sizes and content
      is_same=$(utils::compare "${prev}" "${new}")

      if [[ "${is_same}" == false ]]; then
        # files sizes are different
        # copy $new file content in $prev file
        utils::echo "\n\n### from ${new}" >> "${prev}"
        utils::cat "${new}" >> "${prev}"
      fi
    else
      # file doesn't exist
      # copy file in destination
      utils::cp "${new}" "${dotfiles_to}"
    fi
  done
}

#######################################
# Set dotfiles to /"${OS_PREFIX}"/"${CURRENT_USER}"
# GLOBALS:
#   CURRENT_USER
#   DETACHED
#   INSTANCE_PATH
#   PROFILE_PATH
#   OS_PREFIX
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_set(){
  local dotfile="${1-}"

  if [[ "${DETACHED}" == false ]]; then
    msg::debug "Not detached"
    # duplicate files from profile to instance
    local profile_file="${PROFILE_PATH}"/dotfiles/"${dotfile}"
    local instance_path="$INSTANCE_PATH"/dotfiles/

    # bug : for some reason the utils::cp wrapper wouldn't work here 
    # (maybe paths expansion ?)
    if ! cp "${profile_file}" "${instance_path}"; then
      _error "Can not cp "${profile_file}" in "${instance_path}""
    fi

    # create a symlink between the instance file and the home folder
    ln -sfn "${instance_path}""${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
    # todo : utils::link ??
    # ln -n "${instance_path}""${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
    # utils::link "${instance_path}""${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/

  else
    msg::debug "Detached"
    # if detached copy directly the file to home folder
    utils::cp "${profile_file}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
  fi
  # add entry to instance yaml
  yaml::add "${INSTANCE_YAML}" ".dotfiles.installed" "${dotfile}"
}

#######################################
# Restore dotfiles to /"${OS_PREFIX}"/"${CURRENT_USER}"
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#   OS_PREFIX
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfile_restore(){
  local dotfile="${1-}"
  local sub_path="dotfiles-backup"
  local backup_file="${INSTANCE_PATH}"/"${sub_path}"/"${dotfile}"
  local dest_path="/"${OS_PREFIX}"/"${CURRENT_USER}"/"
  
  if [[ -f ${backup_file} ]]; then
    cmd::run_as_user "cp -R "${backup_file}" "${dest_path}""
  else
    msg::debug "No dotfile to restore found."
    return 0
  fi
}

#######################################
# Unset dotfiles from /"${OS_PREFIX}"/"${CURRENT_USER}"
# GLOBALS:
#   CURRENT_USER
#   OS_PREFIX
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_unset(){
  local dotfile="${1-}"
  local yaml="${INSTANCE_YAML}"
  local selector=".dotfiles.backup"
  local has_backup=$(utils::yq_contains "${yaml}" "${selector}" "${dotfile}")

  utils::remove "/${OS_PREFIX}/${CURRENT_USER}/${dotfile}"

  if [[ "${has_backup}" == true ]]; then
    loco::dotfile_restore "${dotfile}"
  fi
}