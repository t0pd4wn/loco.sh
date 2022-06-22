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
#   PROFILE
# Arguments:
#   $@ # an array of dotfiles
#######################################
loco::dotfiles_action_install(){
  declare -a dotfiles
  dotfiles=("$@")

  msg::print "${EMOJI_YES} Yes, use " "${PROFILE}" " dotfiles"
  msg::print "Preparing your dotfiles backup"

  INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
  # create the backup folder
  utils::mkdir ./"$INSTANCE_PATH/dotfiles-backup"

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
  msg::print "Removing " "${PROFILE}" " dotfiles"

  # remove $PROFILE dotfiles
  for dotfile in "${dotfiles[@]}"; do
    loco::dotfiles_unset "${dotfile}"
  done

  # restore $CURRENT_USER dotfiles
  msg::print "Restoring " "${CURRENT_USER}" " dotfiles"
  loco::dotfiles_restore
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

  # if the file doesn't exist
  if [ ! -f /"${OS_PREFIX}"/"${CURRENT_USER}"/"${dotfile}" ]; then
    msg::debug "/"${OS_PREFIX}"/""${CURRENT_USER}"/"${dotfile}"
    msg::print "No corresponding " "${dotfile}" " file"
  else
    msg::debug "${dotfile}" " is backup'd"
    utils::cp /"${OS_PREFIX}"/"${CURRENT_USER}"/"${dotfile}" ./"$INSTANCE_PATH"/dotfiles-backup/"${dotfile}"
    utils::remove "/"${OS_PREFIX}"/""${CURRENT_USER}"/"${dotfile}"
  fi
}

#######################################
# Set dotfiles to /"${OS_PREFIX}"/"${CURRENT_USER}"
# GLOBALS:
#   CURRENT_USER
#   DETACHED
#   PROFILES_DIR
#   PROFILE
#   OS_PREFIX
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_set(){
  local dotfile="${1-}"
  local current_path=$(pwd)
  
  if [[ "${DETACHED}" == false ]]; then
    msg::debug "Not detached"
    ln -sfn "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
  else
    msg::debug "Detached"
    utils::cp "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /"${OS_PREFIX}"/"${CURRENT_USER}"/
  fi
}

#######################################
# Restore dotfiles to /"${OS_PREFIX}"/"${CURRENT_USER}"
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#   OS_PREFIX
#######################################
loco::dotfiles_restore(){
  if [[ -d ./"$INSTANCE_PATH""/legacy-dotfiles" ]]; then
    cmd::run_as_user "cp -R ./"$INSTANCE_PATH"/legacy-dotfiles/." "/"${OS_PREFIX}"/"${CURRENT_USER}"/" 
  elif [[ -d ./"$INSTANCE_PATH""/dotfiles-backup" ]]; then
    cmd::run_as_user "cp -R ./"$INSTANCE_PATH"/dotfiles-backup/." "/"${OS_PREFIX}"/"${CURRENT_USER}"/" 
  else 
    msg::debug "No dotfiles to restore"
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