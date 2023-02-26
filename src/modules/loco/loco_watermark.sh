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
#   INSTANCE_YAML
#   EMOJI_YES
#   EMOJI_NO
#   OS_PREFIX
#######################################
loco::watermark_check(){        
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # keep a copy of previously recorded messages 
  # meant if $ACTION changes
  local recorded_messages=("${MSG_ARRAY[@]-}")

  # assign yaml files to globals
  loco::yaml_init

  # if no .loco file is found
  if [[ ! -f "${INSTANCE_YAML}" ]]; then
    msg::print "No " "previous instance" " found."
    if [[ "${ACTION}" == "remove" ]]; then
      _exit
    else
      loco::watermark_set


      # # tests
      # local path=/"${OS_PREFIX}"/"${CURRENT_USER}"/locoo
      # local yaml_val
      # yaml_val=$(utils::yq_contains "${path}" ".instance.CURRENT_USER" "Ov")

      # local sel=".packages.ubuntu.apt"
      # local val="zsh"

      # utils::yq_add_key "${path}" ".packages" ".hahaha"

    fi

  # if there is a .loco file
  else
    # if install
    if [[ "${ACTION}" == "install" ]]; then
      loco::watermark_action_install
    # if remove
    elif [[ "${ACTION}" == "remove" ]]; then
      loco::watermark_action_remove "${INSTANCE_YAML}"
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
  msg::print "" "Please, remove or update this instance first."

# remove or update

  msg::prompt "Remove (R) or update (U) the " "installed" " instance ?"
  case ${USER_ANSWER:0:1} in
  # in this case, yes is mapped as remove
  r|R|y )
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
    # reset the yaml .profile path
    loco::yaml_profile
  ;;


  u|U )
    # msg::print "${EMOJI_YES}" " Yes, update instance."
    # # switch to remove
    # ACTION="remove"
    # # keep a copy of current finish script
    # utils::cp "./src/temp/finish.sh" "./src/temp/finish_temp.sh"
    # # source the $ACTION.sh file
    # utils::source ./src/actions/"${ACTION}".sh
    # # remove the newly created finish.sh
    # utils::remove "./src/temp/finish.sh"
    # # put the copy back
    # utils::cp "./src/temp/finish_temp.sh" "./src/temp/finish.sh"
    # # restore a copy of current messages
    # MSG_ARRAY=("${recorded_messages[@]}")
    # # switch back to installation and current profile
    # ACTION="install"
    # PROFILE="${current_profile}"
    # # reset the yaml .profile path
    # loco::yaml_profile
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
# Arguments:
#   $1 # a yaml path "/yaml/path"
#######################################
loco::watermark_action_remove(){
  # utils::source /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
  # msg::print "Profile to be removed : " "${PROFILE}"
  # msg::print "User to be restored : " "${CURRENT_USER}"
  # msg::print "Dotfiles path to be restored : " "${INSTANCE_PATH}"

  # utils::source /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml

  local watermark="${@}"

  PROFILE=$(utils::profile_get_values '.instance.PROFILE' "${watermark}")
  CURRENT_USER=$(utils::profile_get_values '.instance.CURRENT_USER' "${watermark}")
  INSTANCE_PATH=$(utils::profile_get_values '.instance.INSTANCE_PATH' "${watermark}")

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
    utils::source /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
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
#   OS_PREFIX
# Output:
#   Remove .loco file from /"${OS_PREFIX}"/"${CURRENT_USER}"
#######################################
loco::watermark_unset(){
  msg::say "Removing " "watermark"
  utils::remove "${INSTANCE_YAML}"
}

#######################################
# Set a post script watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   INSTANCE_PATH
#   WATERMARK
#   ACTION
#   OS_PREFIX
# Output:
#   Writes .loco file to /"${OS_PREFIX}"/"${CURRENT_USER}"
#######################################
# loco::watermark_set(){
#   if [[ "${WATERMARK}" == true ]]; then
#     utils::echo '#loco.sh instance infos...' > /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
#     utils::echo 'CURRENT_USER='${CURRENT_USER} >> /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
#     utils::echo 'PROFILE='${PROFILE} >> /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
#     utils::echo 'INSTANCE_PATH='${INSTANCE_PATH-} >> /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
#   fi
# }

#######################################
# Init the .yml watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   WATERMARK
#   INSTANCE_YAML
# Output:
#   Writes .loco.yml file to /"${OS_PREFIX}"/"${CURRENT_USER}"/
#######################################
loco::watermark_set(){
  if [[ "${WATERMARK}" == true ]]; then
    utils::echo 'instance:' > "${INSTANCE_YAML}"
    utils::echo '  CURRENT_USER: '${CURRENT_USER} >> "${INSTANCE_YAML}"
    utils::echo '  PROFILE: '${PROFILE} >> "${INSTANCE_YAML}"
    utils::echo '  INSTANCE_PATH: ' >> "${INSTANCE_YAML}"
    utils::echo 'style:' >> "${INSTANCE_YAML}"
    utils::echo 'packages:' >> "${INSTANCE_YAML}"
  fi
}