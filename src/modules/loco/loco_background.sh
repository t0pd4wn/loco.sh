#!/bin/bash
#-------------------------------------------------------------------------------
# loco_background.sh | loco.sh background functions
#-------------------------------------------------------------------------------

#######################################
# Prepare custom functions execution
# GLOBALS:
#   ACTION
#   BACKGROUND_URL
#   LOCO_OSTYPE
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # "entry" or "exit"
#######################################
loco::background_manager(){
  local ab_path=$(pwd)
  local assets_path="${PROFILES_DIR}"/"${PROFILE}"/assets/
  local profile_file_path=$(find "${ab_path}"/"${assets_path}" -name 'background.*' 2>/dev/null)
  local yaml_file_path="${style_background-}"
  local url_file_path="${BACKGROUND_URL:-"${yaml_file_path}"}"
  local local_files_path=./src/backgrounds/
  local img_basename
  local img_clean_name
  local final_path
  local ubuntu_default
  local ubuntu_path

  # if action is install
  if [[ "${ACTION}" == "install" ]]; then
    # if a background url option is set through -B or profile.yaml
    if [[ ! -z "${url_file_path}" ]]; then
      msg::debug "Background url option found."
      utils::get_url "./src/backgrounds" "${url_file_path}"
      img_basename=$(basename "${url_file_path}")
      # clean file name from URI encoded characters
      img_clean_name=$( utils::decode_URI "${img_basename}" )
      final_path="${ab_path}"/src/backgrounds/"${img_clean_name}"

    # or, if a background file is present in /assets/
    elif [[ -f "${profile_file_path}" ]]; then
      msg::debug "Local assets background found."
      final_path="${profile_file_path}" 

    # or, if background(s) file(s) are present in /src/backgrounds
    elif [[ ! -z "$(ls -A "${local_files_path}" 2>/dev/null)" ]]; then
      msg::debug "Backgrounds found in /src/backgrounds/."
      # launch a prompt to select background
      loco::prompt_background
      final_path=$( find "${ab_path}""/src/backgrounds" -name "${BACKGROUND}.*" )
    fi

  # if action is remove
  elif [[ "${ACTION}" == "remove" ]]; then
    if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
      # works for 21.x, 22.x
      ubuntu_default="warty-final-ubuntu.png"
      ubuntu_path=/usr/share/backgrounds/
      final_path="${ubuntu_path}""${ubuntu_default}"
    fi
  fi

  msg::debug "${final_path-}"

  # send the image path to config file
  if [[ ! -z "${final_path-}" ]]; then
    loco::set_background "${final_path}"
  fi
}

#######################################
# Call the themes prompt
# Arguments:
#   $1 // a background uri 
#######################################
loco::set_background(){
  local background_path="${@-}"
  msg::debug "${background_path}"
  local gsettings_opts="org.gnome.desktop.background picture-uri"
  cmd::record "gsettings set" "${gsettings_opts}" "'""${background_path}""'"
  if [[ "$(lsb_release -r -s)" == "22.04" || "22.10" ]]; then
    cmd::record "gsettings set" "${gsettings_opts}""-dark ""'""${background_path}""'"
  fi
}