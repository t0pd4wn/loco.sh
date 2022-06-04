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
  local profile_bg_path=$(find "${ab_path}"/"${assets_path}" -name 'background.*' 2>/dev/null)
  local yaml_bg_url
  yaml_bg_url=$(utils::yaml_get_values '.style.background')
  local bg_url="${BACKGROUND_URL:-"${yaml_bg_url}"}"
  local local_bgs_path=./src/backgrounds/
  local final_path
  local img_basename
  local img_clean_name
  local ubuntu_default
  local ubuntu_path

  # if action is install
  if [[ "${ACTION}" == "install" ]] ||[[ "${ACTION}" == "update" ]]; then
    # if a background url option is set through -B or profile.yaml
    if [[ ! -z "${bg_url}" ]]; then
      msg::print "Background url option found."
      utils::get_url "./src/backgrounds" "${bg_url}"

      # clean file name from URI encoded characters
      img_basename=$(basename "${bg_url}")

      # todo : enhance below to support duckduckgo images
      # there are few problems linked to URLs special characters decoding 
      # as duckduckgo proxies original URLs it is hard to get the correct path 
      # local domain_name=$( echo "${bg_url}" | awk -F/ '{print $3}')
      # if [[ "${domain_name}" == *"duckduckgo.com" ]]; then
      # # this substitution is meant fo correct `wget` colon substitution
      #   img_basename="${img_basename/"%3A"/":"}"
      #   img_basename=$(find "src/backgrounds/" -name '*'${img_basename})
      #   final_path="file://""${ab_path}"/"${img_basename}"
      # fi

      img_clean_name=$( utils::decode_URI "${img_basename}" )
      final_path="${ab_path}"/src/backgrounds/"${img_clean_name}"

    # or, if a background file is present in /assets/
    elif [[ -f "${profile_bg_path}" ]]; then
      msg::print "Local assets background found."
      final_path="${profile_bg_path}" 

    # or, if background(s) file(s) are present in /src/backgrounds
    elif [[ ! -z "$(ls -A "${local_bgs_path}" 2>/dev/null)" ]]; then
      msg::print "Backgrounds found in /src/backgrounds/."
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
  if [[ "${SHORT_OS_VERSION}" == "22" ]]; then
    cmd::record "gsettings set" "${gsettings_opts}""-dark ""'""${background_path}""'"
  fi
}