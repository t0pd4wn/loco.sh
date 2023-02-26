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
  # prompt a dotfiles related y/n question
  msg::prompt "$1" "$2" "$3"
  case ${USER_ANSWER:0:1} in
  y|Y )

  local dotfiles_path="./"${PROFILES_DIR}"/"${PROFILE}"/dotfiles"
  # list profile dotfiles (todo: dump/retrieve from/to .loco)
  utils::list dotfiles "${dotfiles_path}"

  # check if there are dotfiles in $PROFILE
  if [[ -d "${dotfiles_path}" ]]; then

    # $ACTION == "install || update"
    if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" ==  "update" ]]; then
      loco::dotfiles_action_install "${dotfiles[@]}"

    # $ACTION == "remove"
    elif [[ "${ACTION}" == "remove" ]]; then
      loco::dotfiles_action_remove "${dotfiles[@]}"
    fi

    # empty the normative list
    dotfiles=()
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

  if [[ ${INSTANCES_DIR} == "instances" ]]; then
    # if INSTANCES_DIR is the default value
    INSTANCE_PATH="${current_path}"/"${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
  else
    # if INSTANCES_DIR is a custom value
    INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
  fi

  if [[ ${PROFILES_DIR} == "profiles" ]]; then
    # if PROFILES_DIR is the default value
    PROFILE_PATH="${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"
  else
    # if PROFILES_DIR is a custom value
    PROFILE_PATH="${PROFILES_DIR}"/"${PROFILE}"
  fi

  # create the backup and dotfiles folders
  utils::mkdir "${INSTANCE_PATH}/dotfiles-backup"
  
  if [[ ${DETACHED} == false ]]; then
    utils::mkdir "${INSTANCE_PATH}/dotfiles"
  fi

  # create yaml key in /home/$USER/.loco.yml
  utils::yq_change "${INSTANCE_YAML}" ".instance.INSTANCE_PATH" "${INSTANCE_PATH}"
  
  if [[ "${ACTION}" == "update" ]]; then
    loco::dotfiles_action_update
  fi

  # backup $CURRENT_USER dotfiles and install $PROFILE ones
  for dotfile in "${dotfiles[@]}"; do
    # if "${dotfile}" already exists, backup it
    loco::dotfiles_backup "${dotfile}"
    # copy/link "${dotfile}"
    loco::dotfiles_set "${dotfile}"
  done

  msg::say "${CURRENT_USER}" " dotfiles were backup'd here :"
  msg::say "/"$INSTANCE_PATH"/dotfiles-backup"
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
  dotfiles=("$@")

  msg::print "${EMOJI_YES} Yes, remove " "${PROFILE}" " dotfiles"   
  msg::print "Restoring " "${CURRENT_USER}" " dotfiles"

  # remove $PROFILE dotfiles
  for dotfile in "${dotfiles[@]}"; do
    loco::dotfiles_unset "${dotfile}"
    loco::dotfiles_restore "${dotfile}"
  done

}

#######################################
# Dotfiles update procedure
# GLOBALS:
#   INSTANCE_PATH
#   OLD_INSTANCE_PATH
#######################################
loco::dotfiles_action_update(){
  local copy_from
  local copy_to
  # check if a previous backup exist
  if [[ ! -z "${OLD_INSTANCE_PATH-}" ]]; then
    msg::print "Dotfiles path to be updated : " "${OLD_INSTANCE_PATH}"
    if [[ -d "${OLD_INSTANCE_PATH}""/legacy-dotfiles" ]]; then
      backup_suffix="/legacy-dotfiles"
    else
      backup_suffix="/dotfiles-backup"
    fi
    copy_from="${OLD_INSTANCE_PATH}""${backup_suffix}"
    copy_to="${INSTANCE_PATH}""/legacy-dotfiles"
    utils::cp "${copy_from}" "${copy_to}"
  fi
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
  local profile_file="$INSTANCE_PATH"/dotfiles-backup/"${dotfile}"
  local user_file=/"${OS_PREFIX}"/"${CURRENT_USER}"/"${dotfile}"

  # if the file doesn't exist
  if [ ! -f "${user_file}" ]; then
    msg::debug "${user_file}"
    msg::print "No corresponding " "${dotfile}" " file"
  else
    utils::cp "${user_file}" "${profile_file}"
    utils::remove "${user_file}"
    msg::debug "${dotfile}" " is backup'd"
  fi
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

    ls -la "${instance_path}"

    # create a symlink between the instance dir and the home folder
    ln -sfn "${instance_path}""${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
  else
    msg::debug "Detached"
    # if detached copy directly the file to home folder
    utils::cp "${profile_file}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
  fi
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
loco::dotfiles_restore(){
  local dotfile="${1-}"
  local sub_path
  local backup_file
  local dest_path="/"${OS_PREFIX}"/"${CURRENT_USER}"/"

  if [[ -d "${INSTANCE_PATH}/legacy-dotfiles" ]]; then
    sub_path="legacy-dotfiles"
  elif [[ -d "${INSTANCE_PATH}/dotfiles-backup" ]]; then
    sub_path="dotfiles-backup"
  fi

  backup_file="${INSTANCE_PATH}"/"${sub_path}"/"${dotfiles}"
  
  if [[ -f ${backup_file} ]]; then
    cmd::run_as_user "cp -R "${backup_file}" "${dest_path}""
  else
    msg::debug "No dotfile to restore"
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
  utils::remove "/${OS_PREFIX}/${CURRENT_USER}/${dotfile}"
}