#!/bin/bash
#-------------------------------------------------------------------------------
# loco_watermark.sh | loco.sh watermark functions
#-------------------------------------------------------------------------------

########################################
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
########################################
loco::watermark_check(){
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # keep a copy of previously recorded messages 
  # meant if $ACTION changes
  local recorded_messages=("${MSG_ARRAY[@]-}")

  # assign yaml files paths to GLOBALs
  loco::yaml_init

  # if no .loco.yml file is found
  if [[ ! -f "${INSTANCE_YAML}" ]]; then
    msg::print "No " "previous instance" " found."
    if [[ "${ACTION}" == "remove" ]]; then
      _exit
    else
      # create .loco.yml
      loco::watermark_set
    fi

  # if there is a .loco.yml file
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

########################################
# Instance folders creation
# GLOBALS:
#   CURRENT_USER
#   DETACHED
#   INSTANCES_DIR
#   INSTANCE_PATH
#   INSTANCE_YAML
#   PROFILE
########################################
loco::instance_create(){
    local current_path=$(pwd)

    if [[ ${INSTANCES_DIR} == "instances" ]]; then
      # if INSTANCES_DIR is the default value
      INSTANCE_PATH="${current_path}"/"${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
    else
      # if INSTANCES_DIR is a custom value
      INSTANCE_PATH="${INSTANCES_DIR}"/"${CURRENT_USER}"-"${PROFILE}"-$(utils::timestamp)
    fi

    # create the instance folder
    _mkdir "${INSTANCE_PATH}"

    # create sub folders
    _mkdir "${INSTANCE_PATH}/dotfiles-backup"

    if [[ ${DETACHED} == false ]]; then
      _mkdir "${INSTANCE_PATH}/dotfiles"
    fi

    # create yaml key in /home/$USER/.loco.yml
    yaml::change "${INSTANCE_YAML}" ".instance.INSTANCE_PATH" "${INSTANCE_PATH}"
}

########################################
# Watermark install procedure
# GLOBALS:
#   ACTION
#   EMOJI_YES
#   EMOJI_STOP
#   CURRENT_USER
#   PROFILE
#   USER_ANSWER
########################################
loco::watermark_action_install(){
  # keep a copy of current GLOBALs values
  local current_profile="${PROFILE-}"
  local current_user="${CURRENT_USER-}"
  local current_path="${INSTANCE_PATH-}"
  # keep a copy of current messages
  local recorded_messages=("${MSG_ARRAY[@]-}")

  msg::print "${EMOJI_STOP} There is a " "${CURRENT_USER}" " watermark."
  msg::print "" "Please, remove or update this instance."

  # remove or update
  msg::prompt "Remove (r/R) or update (u/U) the " "installed" " instance ?"
  case ${USER_ANSWER:0:1} in
  # in this case, yes is mapped as remove
  # remove the installed instance, then install the new one
  r|R|y|Y )
    msg::print "${EMOJI_YES}" " Yes, remove instance."
    # switch to remove
    ACTION="remove"
    # keep a copy of current finish script
    _cp "./src/temp/finish.sh" "./src/temp/finish_temp.sh"
    # source the $ACTION.sh file
    _source ./src/code/actions/"${ACTION}".sh
    # remove the newly created finish.sh
    utils::remove "./src/temp/finish.sh"
    # put the copy back
    _cp "./src/temp/finish_temp.sh" "./src/temp/finish.sh"
    # restore a copy of current messages
    MSG_ARRAY=("${recorded_messages[@]}")
    # switch back to installation and current profile
    ACTION="install"
    PROFILE="${current_profile}"
    # reset the yaml .profile path
    loco::yaml_init
  ;;

  # update the installed instance
  u|U )
     msg::print "${EMOJI_YES}" " Yes, update instance."
  ;;

  * )
    msg::print "${EMOJI_NO}" " No, I'll keep current instance."
    _exit
  ;;
  esac
}

########################################
# Watermark remove procedure
# GLOBALS:
#   CURRENT_USER
#   INSTANCE_PATH
#   PROFILE
# Arguments:
#   $1 # a yaml path "/yaml/path"
########################################
loco::watermark_action_remove(){
  local profile_array
  local profile_prefix

  PROFILE=$(yaml::get "${INSTANCE_YAML}" '.instance.PROFILE')
  CURRENT_USER=$(yaml::get "${INSTANCE_YAML}" '.instance.CURRENT_USER')
  INSTANCE_PATH=$(yaml::get "${INSTANCE_YAML}" '.instance.INSTANCE_PATH')

  profile_array=(${PROFILE})

  if [[ "${#profile_array[@]}" -eq 1 ]]; then
    profile_prefix="Profile"
  else
    profile_prefix="Profiles"
  fi

  msg::print "${profile_prefix} to be removed : " "${PROFILE}"
  msg::print "User to be restored : " "${CURRENT_USER}"
  msg::print "Dotfiles path to be restored : " "${INSTANCE_PATH}"

  # reset the yaml .profile path
  loco::yaml_init
}

########################################
# Watermark update procedure
# GLOBALS:
#   ACTION
#   EMOJI_YES
#   EMOJI_STOP
#   INSTANCE_PATH
#   CURRENT_USER
#   PROFILE
#   USER_ANSWER
########################################
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
  
  msg::prompt "Update the " "installed" " instance ? (y/n)"
  case ${USER_ANSWER:0:1} in
  y|Y )
    msg::print "${EMOJI_YES}" " Yes, update instance."
    # source GLOBALs file

    # get yaml value for instance path
    local path_selector=".instance.INSTANCE_PATH"
    INSTANCE_PATH=$(yaml::get "${INSTANCE_YAML}" "${path_selector}")

    # add curent profile to instance yaml
    local profile_selector=".instance.PROFILE"
    local previous_profile=$(yaml::get "${INSTANCE_YAML}" "${profile_selector}")
    yaml::change "${INSTANCE_YAML}" "${profile_selector}" "${previous_profile} ${PROFILE}"

    # _source /"${OS_PREFIX}"/"${CURRENT_USER}"/.loco
    # # keep sourced GLOBALs values
    # old_profile="${PROFILE-}"
    # old_user="${CURRENT_USER-}"
    # old_path="${INSTANCE_PATH-}"

    # # keep an old instance path GLOBAL copy
    # OLD_INSTANCE_PATH="${old_path}"
    # # restore previous GLOBALs values
    # PROFILE="${current_profile}"
    # CURRENT_USER="${current_user}"
    # INSTANCE_PATH="${current_path}"
    # loco::watermark_unset
  ;;
  * )
    msg::print "${EMOJI_NO}" " No, I'll keep current instance."
    _exit
  ;;
  esac
}

########################################
# Unset a post script watermark.
# GLOBALS:
#   ACTION
#   CURRENT_USER
#   OS_PREFIX
# Output:
#   Remove .loco file from /"${OS_PREFIX}"/"${CURRENT_USER}"
########################################
loco::watermark_unset(){
  msg::say "Removing " "watermark"
  utils::remove "${INSTANCE_YAML}"
}

########################################
# Init the .yml watermark.
# GLOBALS:
#   CURRENT_USER
#   PROFILE
#   WATERMARK
#   INSTANCE_YAML
# Output:
#   Writes .loco.yml file to /"${OS_PREFIX}"/"${CURRENT_USER}"/
########################################
loco::watermark_set(){
  if [[ "${WATERMARK}" == true ]]; then
    _echo 'instance:' > "${INSTANCE_YAML}"
    _echo '  CURRENT_USER: '${CURRENT_USER} >> "${INSTANCE_YAML}"
    _echo '  PROFILE: '${PROFILE} >> "${INSTANCE_YAML}"
    _echo '  INSTANCE_PATH: ' >> "${INSTANCE_YAML}"
    _echo 'style:' >> "${INSTANCE_YAML}"
    _echo 'packages:' >> "${INSTANCE_YAML}"
    _echo 'dotfiles:' >> "${INSTANCE_YAML}"
    _echo 'profiles:' >> "${INSTANCE_YAML}"

    # populate ".dotfiles.legacy" with existing dotfiles
    local home_path=/"${OS_PREFIX}"/"${CURRENT_USER}"

    utils::list "home_dotfiles" "${home_path}" "hidden"

    for file in "${home_dotfiles[@]}"; do
      local filename=$(utils::string_cut_rev "${file}" "/" "1")
      # add filename to ".dotfiles.legacy"
      yaml::add "${INSTANCE_YAML}" ".dotfiles.legacy" "${filename}"
    done

    for import in "${LOCO_IMPORT_PROFILES[@]}"; do
      yaml::add "${INSTANCE_YAML}" ".profiles.import" "${import}"
    done

    utils::list "home_dotfiles" "${home_path}" "hidden"

    for file in "${home_dotfiles[@]}"; do
      local filename=$(utils::string_cut_rev "${file}" "/" "1")
      # add filename to ".dotfiles.legacy"
      yaml::add "${INSTANCE_YAML}" ".dotfiles.legacy" "${filename}"
    done
  fi
}