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
    prompt::build "ACTION" "./src/actions" "Choose an action :" true
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
  local style_background
  style_background=$(utils::profile_get_values '.style.background')

  # if action "update", check for existing background
  if [[ "${ACTION}" == "update" ]]; then
    local watermark=/"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml
    local watermark_bkg=$(utils::yq '.style.background' "${watermark}")
    if [[ "${watermark_bkg}" != "" ]]; then
      msg::prompt "Do you want to update your " "current background " "? (y/n) "
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES} Yes, I'll update my " "current background"
      ;;
      * )
        msg::print "${EMOJI_NO} No, I'll keep my " "current background"
        return 0
      ;;
      esac
    fi
  fi

  if [ -z "${style_background:-"${BACKGROUND}"}" ]; then
    prompt::build "BACKGROUND" "./src/backgrounds/" "Choose a background:" false
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
    prompt::build "OVERLAY_PATH" "./src/background-overlays/" "Choose an overlay:" false
    prompt::call "OVERLAY_PATH"
  fi
}


#######################################
# Call the profiles prompt
# Globals:
#   PROFILE
#######################################
loco::prompt_profile(){
  if [ -z "${PROFILE}" ]; then
    prompt::build "PROFILE" "./"${PROFILES_DIR}"" "Choose a profile :" true
    prompt::call "PROFILE"
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
    return 0
  fi

  # if action "update", check for existing style
  if [[ "${ACTION}" == "update" ]]; then
    local watermark=/"${OS_PREFIX}"/"${CURRENT_USER}"/.loco.yml
    local watermark_style=$(utils::yq '.style.colors.theme' "${watermark}")
    if [[ "${watermark_style}" != "" ]]; then
      msg::prompt "Do you want to update your current " "style " "? (y/n) "
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_YES} Yes, I'll update my current " "style"
      ;;
      * )
        msg::print "${EMOJI_NO} No, I'll keep my current " "style"
        THEME="${watermark_style}"
        return 0
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
    prompt::build "THEME" "./src/themes" "Choose a color theme :" false
    prompt::call "THEME"
  else
    THEME="${THEME:-${profile_style}}"
  fi

  # writes theme to watermark
  utils::yq_change "${INSTANCE_YAML}" ".style.colors.theme" "${THEME}"
}