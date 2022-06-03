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
  # prompt a y/n question
  msg::prompt "$1" "$2" "$3"
  case ${USER_ANSWER:0:1} in
  y|Y )
  # install PROFILE dotfiles
  local dotfiles_path="./"${PROFILES_DIR}"/"${PROFILE}"/dotfiles"
  # list profile dotfiles (shall be dumped/retrieved from/to .loco)
  utils::list dotfiles "${dotfiles_path}"
  msg::debug ${dotfiles[@]}

  # check if there are dotfiles in $PROFILE
  if [[ -d "${dotfiles_path}" ]]; then

    # $ACTION == "install"
    if [[ "${ACTION}" == "install" ]]; then
      msg::print "${EMOJI_YES} Yes, use " "${PROFILE}" " dotfiles"
      msg::print "Preparing your dotfiles backup"
      INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
      # create the backup folder
      utils::mkdir ./"$INSTANCE_PATH/dotfiles-backup"

      # backup $CURRENT_USER dotfiles and install $PROFILE ones
      for dotfile in "${dotfiles[@]}"; do

        # if "${dotfile}" already exists, backup it
        loco::dotfiles_backup "${dotfile}"

        # copy/link "${dotfile}"
        loco::dotfiles_set "${dotfile}"

        msg::say "${CURRENT_USER}" " dotfiles were backup'd here :"
        msg::say "/"$INSTANCE_PATH"/dotfiles-backup"

      done

    # $ACTION == "remove"
    elif [[ "${ACTION}" == "remove" ]]; then
      msg::print "${EMOJI_YES} Yes, remove " "${PROFILE}" " dotfiles"   
      msg::print "Removing " "${PROFILE}" " dotfiles"

      # remove $PROFILE dotfiles
      for dotfile in ${dotfiles[@]}; do
        loco::dotfiles_unset "${dotfile}"
      done

      # restore $CURRENT_USER dotfiles
      msg::print "Restoring " "${CURRENT_USER}" " dotfiles"
      loco::dotfiles_restore
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
# Set dotfiles to /home/$USER 
# GLOBALS:
#   CURRENT_USER
#   DETACHED
#   PROFILES_DIR
#   PROFILE
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_set(){
  local dotfile="${1-}"
  local current_path=$(pwd)
  if [[ "${DETACHED}" == false ]]; then
    msg::debug "Not detached"
    ln -sfn "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
  else
    msg::debug "Detached"
    utils::cp "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
    # cp -R "${current_path}"/"${PROFILES_DIR}"/"${PROFILE}"/dotfiles/"${dotfile}" /home/"${CURRENT_USER}"/
  fi
}

#######################################
# Unset dotfiles from /home/$USER 
# GLOBALS:
#   CURRENT_USER
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_unset(){
  local dotfile="${1-}"
  utils::remove "/home/${CURRENT_USER}/${dotfile}"
}

#######################################
# Backup dotfiles to $INSTANCE_PATH
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
# Arguments:
#   $1 # a dotfile name
#######################################
loco::dotfiles_backup(){
  local dotfile="${1-}"
  if [ ! -f /home/"${CURRENT_USER}"/"${dotfile}" ]; then
    msg::debug "No corresponding file"
  else 
    msg::debug "${dotfile}" " is backup'd"
    utils::cp /home/"${CURRENT_USER}"/"${dotfile}" ./"$INSTANCE_PATH"/dotfiles-backup/"${dotfile}"
    # cp -R /home/"${CURRENT_USER}"/"${dotfile}" ./"$INSTANCE_PATH"/dotfiles-backup/"${dotfile}"
    # remove existing file 
    utils::remove "/home/""${CURRENT_USER}"/"${dotfile}"
  fi
}

#######################################
# Restore dotfiles to /home/$USER 
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#######################################
loco::dotfiles_restore(){
  if [[ -d ./"$INSTANCE_PATH"/dotfiles-backup ]]; then
    cmd::run_as_user "cp -R ./"$INSTANCE_PATH"/dotfiles-backup/." "/home/"${CURRENT_USER}"/" 
  else 
    msg::debug "No dotfiles to restore"
  fi
}