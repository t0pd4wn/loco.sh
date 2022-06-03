#!/bin/bash
#-------------------------------------------------------------------------------
# loco_fonts.sh | loco.sh fonts functions
#-------------------------------------------------------------------------------

#######################################
# Manages fonts installation and removal
# Ref : https://www.linuxshelltips.com/export-import-gnome-terminal-profile/
# GLOBALS:
#   styles_fonts # yaml font array
# Arguments:
#   ACTION
#   PROFILE
# Output:
#   /home/$USER/.fonts/[fonts]
#######################################
loco::fonts_manager(){
  local font
  local yaml_fonts
  local yaml_fonts=$(utils::yaml_get_values '.style.fonts.urls.[]')
  declare -a yaml_fonts_array
  yaml_fonts_array=("${yaml_fonts}")

  msg::debug "${yaml_fonts_array[@]}"
  msg::debug "${yaml_fonts_array[0]}"

  local assets_fonts=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/
  local fonts_path=/home/"${CURRENT_USER}"/.fonts

  # check for yaml fonts 
  if [[ -z "${yaml_fonts}" ]]; then
    msg::print "No YAML fonts found."
  else 
    msg::say "YAML " "fonts" " processed."
    # IFS=' ' read -r -a fonts_array <<< "${yaml_fonts}"

    for i in "${yaml_fonts_array[@]}"; do
      font=${i}
      # install yaml fonts
      if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
        loco::fonts_action_install_yaml "${fonts_path}" "${font}"
      # remove yaml fonts
      elif [[ "${ACTION}" == "remove" ]]; then
        loco::fonts_action_remove_yaml "${fonts_path}" "${font}"
      fi
    done
  fi

  # check for /assets/fonts/ fonts
  if [[ -z "$(ls -A "${assets_fonts}" 2>/dev/null)" ]]; then
    msg::print "No fonts found in /assets/fonts/."
  else
    msg::say "/assets/ " "fonts" " processed."
    # install local fonts
    if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
      loco::fonts_action_install_local "${fonts_path}"
    # remove local fonts
    elif [[ "${ACTION}" == "remove" ]]; then
      loco::fonts_action_remove_local
    fi
  fi
}

#######################################
# Fonts install yaml procedure
# Arguments:
#   $1 # fonts destination path
#   $2 # a font url
#######################################
loco::fonts_action_install_yaml(){
  local fonts_path="${1-}"
  local font="${2-}"
  utils::mkdir "${fonts_path}"
  # download the font
  utils::get_url "${fonts_path}" "${font}"
  # refresh fonts cache
  loco::fonts_cache_refresh "${fonts_path}"
}

#######################################
# Fonts remove yaml procedure
# Arguments:
#   $1 # fonts destination path
#   $2 # a font url
#######################################
loco::fonts_action_remove_yaml(){
  local fonts_path="${1-}"
  local font="${2-}"
  local font_name
  local font_path
  # instanciate $font_name_array with $font
  IFS='/' read -r -a font_name_array <<< "${font}"
  font_name=${font_name_array[-1]}

  # get clean system path
  font_name=$(utils::decode_URI "${font_name}")
  # font_name=$(utils::escape_string "${font_name}")
  font_path=${fonts_path}/${font_name}

  # if the file exist, remove it
  loco::font_unset "${font_path}"

  # refresh fonts cache
  loco::fonts_cache_refresh "${fonts_path}"
}

#######################################
# Fonts install local assets procedure
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # fonts destination path
#######################################
loco::fonts_action_install_local(){
  local fonts_path="${1-}"
  local from_path=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/*
  utils::mkdir "${fonts_path}"
  utils::cp "${from_path}" "${fonts_path}"
}

#######################################
# Fonts remove local assets procedure
# GLOBALS:
#   PROFILE
#   PROFILES_DIR
#######################################
loco::fonts_action_remove_local(){
  local font_name
  local font_path
  # get a list of fonts as a bash array
  utils::list "fonts" "./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts"
  # loop over the local fonts list
  for font in "${fonts[@]}"; do
    # get clean system path
    font_name=$(utils::decode_URI "${font}")
    # font_name=$(utils::escape_string "${font}")
    local font_path="${fonts_path}"/"${font_name}"
    # if the file exist, remove it
    loco::font_unset "${font_path}"
  done
}

#######################################
# Font removal
# Arguments:
#   $1 # a font destination path
#######################################
loco::font_unset(){
  local font_path="${1-}"
  if [[ ! -f "${font_path}" ]]; then
    msg::debug "Font not found."
  else 
    utils::remove_file "${font_path}"
  fi
}

#######################################
# Refresh fonts cache
# Arguments:
#   $1 # fonts destination path
#######################################
loco::fonts_cache_refresh(){
  local fonts_path="${1-}"
  cmd::run_as_user "fc-cache -fr ""${fonts_path}"
}