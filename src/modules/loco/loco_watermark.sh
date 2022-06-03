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
  local current_profile="${PROFILE}"
  local recorded_messages=("${MSG_ARRAY[@]}")
  if [[ ! -f /home/"${CURRENT_USER}"/.loco ]]; then
    msg::print "No " "previous instance" " found."
    if [[ "${ACTION}" == "remove" ]]; then
      _exit
    fi
  else
    if [[ "${ACTION}" == "install" ]]; then
      msg::print "${EMOJI_STOP} There is a " "${CURRENT_USER}" " watermark."
      msg::print "" "Please, remove this instance first."
      msg::prompt "Remove the installed instance ?"
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES}" " Yes, remove instance."
        # switch to remove
        ACTION="remove"
        # keep a copy of current finish script
        utils::cp "./src/temp/finish.sh" "./src/temp/finish_temp.sh"
        utils::source ./src/actions/"${ACTION}".sh
        # keep a copy of current messages
        # switch back to installation
        # remove the newly created finish.sh
        utils::remove "./src/temp/finish.sh"
        # put the copy back
        utils::cp "./src/temp/finish_temp.sh" "./src/temp/finish.sh"
        # keep a copy of current messages
        MSG_ARRAY=("${recorded_messages[@]}")
        ACTION="install"
        PROFILE="${current_profile}"
      ;;
      * )
        msg::print "${EMOJI_NO}" " No, I'll keep current instance."
        _exit
      ;;
      esac
    elif [[ "${ACTION}" == "remove" ]]; then
      utils::source /home/"${CURRENT_USER}"/.loco
      msg::print "Profile to be removed : " "${PROFILE}"
      msg::print "User to be restored : " "${CURRENT_USER}"
      msg::print "Dotfiles path to be restored : " "${INSTANCE_PATH}"
    fi
  fi
}

#######################################
# set / unset a post script watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   INSTANCE_PATH
#   WATERMARK
#   ACTION
# Output:
#   Writes/rm .loco file to /home/
#######################################
loco::watermark_set(){
  if [[ "${ACTION}" == "remove" ]]; then
    msg::say "Removing " "watermark"
    utils::remove /home/${CURRENT_USER}/.loco
  elif [[ "${WATERMARK}" == true ]]; then
    utils::echo '#loco.sh instance infos...' > /home/"${CURRENT_USER}"/.loco
    utils::echo 'CURRENT_USER='${CURRENT_USER} >> /home/"${CURRENT_USER}"/.loco
    utils::echo 'PROFILE='${PROFILE} >> /home/"${CURRENT_USER}"/.loco
    utils::echo 'INSTANCE_PATH='${INSTANCE_PATH-} >> /home/"${CURRENT_USER}"/.loco
  fi
}