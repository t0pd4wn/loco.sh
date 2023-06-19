#!/bin/bash
#-------------------------------------------------------------------------------
# loco_prompts.sh | loco.sh prompts calls
#-------------------------------------------------------------------------------

########################################
# Call the actions prompt
# Globals:
#   ACTION
########################################
loco::prompt_action(){
  if [ -z "${ACTION}" ]; then
    prompt::build "ACTION" "./src/code/actions" "Choose an action :" true
    prompt::call "ACTION"
  fi
}

########################################
# Call the backgrounds prompt
# Globals:
#   ACTION
#   BACKGROUND
#   INSTANCE_YAML
#   PROFILE_YAML
#   USER_ANSWER
########################################
loco::prompt_background(){
  local profile_bkg
  profile_bkg=$(yaml::get "${PROFILE_YAML}" '.style.background')

  # if action "update", check for new profile background
  if [[ "${ACTION}" == "update" ]]; then
    local watermark_bkg=$(yaml::get "${INSTANCE_YAML}" '.style.background')
    if [[ "${watermark_bkg}" != "" ]]; then
      msg::prompt "Do you want to change your " "current background " "? (y/n) "
      case ${USER_ANSWER:0:1} in
      y|Y )
        msg::print "${EMOJI_NO} Yes, I'll change my " "current background"
      ;;
      * )
        msg::print "${EMOJI_YES} No, I'll keep my " "current background"
        return 0
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

########################################
# Call the overlays prompt
# Globals:
#   style_overlay
#   OVERLAY
########################################
loco::prompt_overlay(){
  local style_overlay
  style_overlay=$(yaml::get_child_values '.style.overlay')

  if [ -z "${style_overlay:-"${OVERLAY_PATH}"}" ]; then
    prompt::build "OVERLAY_PATH" "./src/assets/background-overlays/" "Choose an overlay:" false
    prompt::call "OVERLAY_PATH"
  fi
}

########################################
# Call the profiles prompt
# Globals:
#   PROFILE
########################################
loco::prompt_profile(){
  # if no $PROFILE option is set, launch prompt
  if [ -z "${PROFILE}" ]; then
    prompt::build "PROFILE" "./"${PROFILES_DIR}"" "Choose a profile :" true
    prompt::call "PROFILE"
  fi

  loco::profile_prepare "${PROFILE}"
}

########################################
# Call the themes prompt
# Globals:
#   OS_PREFIX
#   CURRENT_USER
#   INSTANCE_YAML
#   PROFILE_YAML
#   THEME
########################################
loco::prompt_theme(){
  local profile_style=$(yaml::get "${PROFILE_YAML}" '.style.colors.theme')
  local local_theme=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf

  # if macos, exit
  if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    msg::print "Themes are not supported over macOS"
    return 1
  fi

  # if action "update", check for existing style
  if [[ "${ACTION}" == "update" ]]; then
    local watermark_style=$(yaml::get "${INSTANCE_YAML}" '.style.colors.theme')

    # if a theme is already set
    if [[ -n "${watermark_style}" ]]; then
      # if there is a theme in the profile
      if [[ -n "${profile_style}" ]] || [[ -f "${local_theme}" ]]; then
        msg::prompt "Do you want to change your current " "style " "? (y/n) "
        case ${USER_ANSWER:0:1} in
        y|Y )
          msg::print "${EMOJI_NO} Yes, I'll change my current " "style"
        ;;
        * )
          msg::print "${EMOJI_YES} No, I'll keep my current " "style"
          THEME="${watermark_style}"
          return 0
        ;;
        esac
      # if there is no new theme
      else
        msg::print "No theme present in " "${PROFILE}" " profile"
        THEME="${watermark_style}"
        return 0
      fi
    fi
  fi

  # if no theme is set, launch a prompt
  if [ -z "${profile_style:-"${THEME}"}" ] &&  [ ! -f "${local_theme}" ] ; then
    prompt::build "THEME" "./src/assets/themes" "Choose a color theme :" false
    prompt::call "THEME"
  else
    THEME="${THEME:-${profile_style}}"
  fi

  # writes theme to watermark
  yaml::change "${INSTANCE_YAML}" ".style.colors.theme" "${THEME}"
}