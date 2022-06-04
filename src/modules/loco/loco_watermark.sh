#!/bin/bash
#-------------------------------------------------------------------------------
# loco_watermark.sh | loco.sh watermark functions
#-------------------------------------------------------------------------------

#######################################
# Check for watermark presence
# GLOBALS:
#   CURRENT_USER
#   ACTION
#   PROFILE
#   INSTANCE_PATH
#   EMOJI_YES
#   EMOJI_NO
#######################################
loco::watermark_check(){        
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # keep a copy of previously recorded messages
  local recorded_messages=("${MSG_ARRAY[@]-}")

  # if no .loco file is found
  if [[ ! -f /home/"${CURRENT_USER}"/.loco ]]; then
    msg::print "No " "previous instance" " found."
    if [[ "${ACTION}" == "remove" ]]; then
      _exit
    fi
  # if there is a .loco file
  else
    # if install
    if [[ "${ACTION}" == "install" ]]; then
      loco::watermark_action_install
    # if remove
    elif [[ "${ACTION}" == "remove" ]]; then
      loco::watermark_action_remove
    # if update
    elif [[ "${ACTION}" == "update" ]]; then
      loco::watermark_action_update
    fi
  fi
}

#######################################
# Watermark install procedure
# GLOBALS:
#   ACTION
#   EMOJI_YES
#   EMOJI_STOP
#   CURRENT_USER
#   PROFILE
#   USER_ANSWER
#######################################
loco::watermark_action_install(){
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # keep a copy of current messages
  local recorded_messages=("${MSG_ARRAY[@]-}")

  msg::print "${EMOJI_STOP} There is a " "${CURRENT_USER}" " watermark."
  msg::print "" "Please, remove this instance first."
  msg::prompt "Remove the " "installed" " instance ?"
  case ${USER_ANSWER:0:1} in
  y|Y )
    msg::print "${EMOJI_YES}" " Yes, remove instance."
    # switch to remove
    ACTION="remove"
    # keep a copy of current finish script
    utils::cp "./src/temp/finish.sh" "./src/temp/finish_temp.sh"
    # source the $ACTION.sh file
    utils::source ./src/actions/"${ACTION}".sh
    # remove the newly created finish.sh
    utils::remove "./src/temp/finish.sh"
    # put the copy back
    utils::cp "./src/temp/finish_temp.sh" "./src/temp/finish.sh"
    # restore a copy of current messages
    MSG_ARRAY=("${recorded_messages[@]}")
    # switch back to installation and current profile
    ACTION="install"
    PROFILE="${current_profile}"
  ;;
  * )
    msg::print "${EMOJI_NO}" " No, I'll keep current instance."
    _exit
  ;;
  esac
}

#######################################
# Watermark remove procedure
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#   PROFILE
#######################################
loco::watermark_action_remove(){
  utils::source /home/"${CURRENT_USER}"/.loco
  msg::print "Profile to be removed : " "${PROFILE}"
  msg::print "User to be restored : " "${CURRENT_USER}"
  msg::print "Dotfiles path to be restored : " "${INSTANCE_PATH}"
}

#######################################
# Watermark update procedure
# GLOBALS:
#   ACTION
#   EMOJI_YES
#   EMOJI_STOP
#   INSTANCE_PATH
#   CURRENT_USER
#   PROFILE
#   USER_ANSWER
#######################################
loco::watermark_action_update(){
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # other locals
  local old_profile
  local old_user
  local old_path

  msg::print "${EMOJI_STOP} There is a " "${CURRENT_USER}" " watermark."
  
  msg::prompt "Update the " "installed" " instance ?"
  case ${USER_ANSWER:0:1} in
  y|Y )
    msg::print "${EMOJI_YES}" " Yes, update instance."
    # source GLOBALs file
    utils::source /home/"${CURRENT_USER}"/.loco
    # keep sourced GLOBALs values
    old_profile="${PROFILE-}"
    old_user="${CURRENT_USER-}"
    old_path="${INSTANCE_PATH-}"
    # keep an old instance path GLOBAL copy
    OLD_INSTANCE_PATH="${old_path}"
    # restore previous GLOBALs values
    PROFILE="${current_profile}"
    CURRENT_USER="${current_user}"
    INSTANCE_PATH="${current_path}"
    loco::watermark_unset
  ;;
  * )
    msg::print "${EMOJI_NO}" " No, I'll keep current instance."
    _exit
  ;;
  esac
}

#######################################
# Unset a post script watermark.
# GLOBALS:
#   ACTION
#   CURRENT_USER
# Output:
#   Remove .loco file from /home/$USER
#######################################
loco::watermark_unset(){
  msg::say "Removing " "watermark"
  utils::remove /home/${CURRENT_USER}/.loco
}

#######################################
# Set a post script watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   INSTANCE_PATH
#   WATERMARK
#   ACTION
# Output:
#   Writes .loco file to /home/$USER
#######################################
loco::watermark_set(){
  if [[ "${WATERMARK}" == true ]]; then
    utils::echo '#loco.sh instance infos...' > /home/"${CURRENT_USER}"/.loco
    utils::echo 'CURRENT_USER='${CURRENT_USER} >> /home/"${CURRENT_USER}"/.loco
    utils::echo 'PROFILE='${PROFILE} >> /home/"${CURRENT_USER}"/.loco
    utils::echo 'INSTANCE_PATH='${INSTANCE_PATH-} >> /home/"${CURRENT_USER}"/.loco
  fi
}