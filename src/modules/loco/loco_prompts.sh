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
  style_background=$(utils::yaml_get_values '.style.background')

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
  style_overlay=$(utils::yaml_get_values '.style.overlay')

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
#   style_colors_theme
#   THEME
#######################################
loco::prompt_theme(){
  local style_colors_theme
  style_colors_theme=$(utils::yaml_get_values '.style.colors.theme')
  local local_theme=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf


  if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    msg::print "Themes are not supported over macOS"
    return 0
  fi

  # if no theme is set, launch a prompt
  if [ -z "${style_colors_theme:-"${THEME}"}" ] &&  [ ! -f "${local_theme}" ] ; then
    prompt::build "THEME" "./src/themes" "Choose a color theme :" false
    prompt::call "THEME"
  fi
}