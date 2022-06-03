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
# Call the themes prompt
# Globals:
#   style_background
#   BACKGROUND
#######################################
loco::prompt_background(){
  if [ -z "${style_background-"${BACKGROUND}"}" ]; then
    prompt::build "BACKGROUND" "./src/backgrounds/" "Choose a background:" false
    prompt::call "BACKGROUND"
  fi
}

#######################################
# Call the profiles prompt
# Globals:
#   PROFILE
#######################################
loco::prompt_profile(){
  if [ -z "${PROFILE}" ]; then
    prompt::build "PROFILE" "./profiles" "Choose a profile :" true
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

  # if no theme is set, launch a prompt
  if [ -z "${style_colors_theme-"${THEME}"}" ]; then
    prompt::build "THEME" "./src/themes" "Choose a color theme :" false
    prompt::call "THEME"
  fi
}