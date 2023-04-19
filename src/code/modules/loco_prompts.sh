#!/bin/bash
#-------------------------------------------------------------------------------
# loco_prompts.sh | loco.sh prompts calls
#-------------------------------------------------------------------------------

#######################################
# Call the actions prompt
# Globals:
#   ACTION
#######################################
loco::prompt_action(){
  if [ -z "${ACTION}" ]; then
    prompt::build "ACTION" "./src/code/actions" "Choose an action :" true
    prompt::call "ACTION"
  fi
}

#######################################
# Call the backgrounds prompt
# Globals:
#   style_background
#   BACKGROUND
#######################################
loco::prompt_background(){
  local profile_bkg
  profile_bkg=$(yaml::get "${PROFILE_YAML}" '.style.background')

  # if action "update", check for existing background
  if [[ "${ACTION}" == "update" ]]; then
    local watermark_bkg=$(yaml::get "${INSTANCE_YAML}" '.style.background')
    if [[ "${watermark_bkg}" != "" ]]; then
      msg::prompt "Do you want to keep your " "current background " "? (y/n) "
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES} Yes, I'll keep my " "current background"
        return 0
      ;;
      * )
        msg::print "${EMOJI_NO} No, I'll update my " "current background"
      ;;
      esac
    fi
  fi

  if [ -z "${profile_bkg:-"${BACKGROUND}"}" ]; then
    prompt::build "BACKGROUND" "./src/assets/backgrounds/" "Choose a background:" false
    prompt::call "BACKGROUND"

    msg::debug "${BACKGROUND}"
  fi
}

#######################################
# Call the overlays prompt
# Globals:
#   style_overlay
#   OVERLAY
#######################################
loco::prompt_overlay(){
  local style_overlay
  style_overlay=$(utils::profile_get_values '.style.overlay')

  if [ -z "${style_overlay:-"${OVERLAY_PATH}"}" ]; then
    prompt::build "OVERLAY_PATH" "./src/assets/background-overlays/" "Choose an overlay:" false
    prompt::call "OVERLAY_PATH"
  fi
}

#######################################
# Call the profiles prompt
# Globals:
#   PROFILE
#######################################
loco::prompt_profile(){
  # if no $PROFILE option is set
  if [ -z "${PROFILE}" ]; then
    prompt::build "PROFILE" "./"${PROFILES_DIR}"" "Choose a profile :" true
    prompt::call "PROFILE"
  else
    # if a $PROFILE option is set
    # split the option on the "," character 
    declare -a profile_option
    profile_option=($(echo "${PROFILE}" | tr "," " "))

    local profile_length=${#profile_option[@]}

    # if there is more than one profile, merge profiles
    if [[ "${profile_length}" -gt 1 ]]; then
      loco::multi_prepare "${profile_option[@]}"
    fi
  fi
}

#######################################
# Call the themes prompt
# Globals:
#   OS_PREFIX
#   CURRENT_USER
#   THEME
#######################################
loco::prompt_theme(){
  # if macos, exit
  if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    msg::print "Themes are not supported over macOS"
    return 1
  fi

  # if action "update", check for existing style
  if [[ "${ACTION}" == "update" ]]; then
    local watermark_style=$(yaml::get "${INSTANCE_YAML}" '.style.colors.theme')
    if [[ "${watermark_style}" != "" ]]; then
      msg::prompt "Do you want to keep your current " "style " "? (y/n) "
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES} Yes, I'll keep my current " "style"
        THEME="${watermark_style}"
        return 0
      ;;
      * )
        msg::print "${EMOJI_NO} No, I'll update my current " "style"
      ;;
      esac
    fi
  fi

  # check for profile style
  local profile_style
  profile_style=$(utils::profile_get_values '.style.colors.theme')

  # check for profile terminal file
  local local_theme=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf

  # if no theme is set, launch a prompt
  if [ -z "${profile_style:-"${THEME}"}" ] &&  [ ! -f "${local_theme}" ] ; then
    prompt::build "THEME" "./src/assets/themes" "Choose a color theme :" false
    prompt::call "THEME"
  else
    THEME="${THEME:-${profile_style}}"
  fi

  # writes theme to watermark
  utils::yq_change "${INSTANCE_YAML}" ".style.colors.theme" "${THEME}"
}