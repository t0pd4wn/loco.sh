#!/bin/bash
#-------------------------------------------------------------------------------
# loco_background.sh | loco.sh background functions
#-------------------------------------------------------------------------------

#######################################
# Prepare background installation
# GLOBALS:
#   ACTION
#   INSTANCE_YAML
#######################################
loco::background_manager(){
  local local_bgs_path=./src/assets/backgrounds/
  local previous_bg_url
  local final_path

  # if action is install
  if [[ "${ACTION}" == "install" ]]; then
    # set the background to ${final_path} through a normative array
    loco::set_background "final_path"

    # save current background
    if [[ -n "${final_path}" ]]; then
      loco::get_current_background
    fi

  # if action is update
  elif [[ "${ACTION}" == "update" ]]; then
    # set the background to ${final_path} through a normative array
    loco::set_background "final_path"

    # in case $ACTION is "update" and the old background is kept
    # set $final_path to the previous background path
    if [[ -z "${final_path-}" ]]; then
      previous_bg_url=$(yaml::get "${INSTANCE_YAML}" '.style.background')
      if [[ -n "${previous_bg_url}" ]]; then
        final_path="${previous_bg_url}"
        # todo : else retrieve legacy background ?
      fi
    fi

  # if action is remove
  elif [[ "${ACTION}" == "remove" ]]; then
    final_path=$(loco::unset_background)
  fi

  # if there is a background file selected
  if [[ -n "${final_path}" ]]; then
    # if the OVERLAY -o flag is set
    if [[ "${OVERLAY}" == true ]]; then
      loco::overlay_manager "${final_path}"
    # if not
    else
      # send the image path to config file
      loco::register_background "${final_path}"
    fi
      # save background path in ~/.loco.yml
      yaml::change "${INSTANCE_YAML}" ".style.background" "${final_path}"
  fi
}

#######################################
# Set the selected loco background
# GLOBALS:
#   BACKGROUND_URL
#   PROFILE
#   PROFILES_DIR
#   PROFILES_YAML
# Arguments:
#   $1 # a normative array name
#######################################
loco::set_background(){
  local ab_path=$(pwd)
  local assets_path="${PROFILES_DIR}"/"${PROFILE}"/assets/
  local profile_bg_path=$(find "${ab_path}"/"${assets_path}" -name 'background.*' 2>/dev/null)
  local yaml_bg_url=$(yaml::get "${PROFILE_YAML}" '.style.background')
  local bg_option="${BACKGROUND_URL:-"${yaml_bg_url}"}"
  declare -n img_path="${1-}"

  # if a background option is set through -B or profile.yaml
  if [[ -n "${bg_option}" ]]; then
    if [[ "${bg_option}" == "http"* ]]; then
      msg::print "Background option url found."
      img_path=$(loco::get_background_url "${bg_option}" "${ab_path}") 
    else
      msg::print "Background option path found."
      img_path=$(loco::get_background_path "${bg_option}" "${ab_path}")
  fi

  # or, if a background file is present in /assets/
  elif [[ -f "${profile_bg_path}" ]]; then
    msg::print "Local assets background found."
    img_path="${profile_bg_path}" 
  # or, if background(s) file(s) are present in /src/assets/backgrounds
  elif [[ ! -z "$(ls -A "${local_bgs_path}" 2>/dev/null)" ]]; then
    msg::print "Backgrounds found in /src/assets/backgrounds/."
    # launch a prompt to select background
    loco::prompt_background
    img_path=$(find "${ab_path}""/src/assets/backgrounds" -name "${BACKGROUND}.*" | tail -n 1)
  fi
}

#######################################
# Unset the loco background and set a default or legacy one
# GLOBALS:
#   LOCO_OSTYPE
#   INSTANCE_YAML
#   SHORT_OS_VERSION
#######################################
loco::unset_background(){
  local os_default_bg
  local os_path
  local img_path
  local legacy_path=$(yaml::get ${INSTANCE_YAML} ".style.legacy_background")

  # if there is a legacy path and if the file still exist
  # assign this file to background
  if [[ -f "${legacy_path}" ]]; then
      img_path="${legacy_path}"
  else
    if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
      # works for 22.x+
      os_default_bg="warty-final-ubuntu.png"
      os_path=/usr/share/backgrounds/
      img_path="${os_path}""${os_default_bg}"
    elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
      if [[ "${SHORT_OS_VERSION}" -eq 13 ]]; then
        os_default_bg="Ventura Graphic.heic"
      else
        os_default_bg="Monterey Graphic.heic"
      fi
      os_path="/System/Library/Desktop Pictures/"
      img_path="${os_path}""${os_default_bg}"
    fi
  fi

  _echo "${img_path}" 
}

#######################################
# Call the themes prompt
# GLOBALS:
#   LOCO_OSTYPE
#   SHORT_OS_VERSION
# Arguments:
#   $1 # a background path
#######################################
loco::register_background(){
  local background_path="${@-}"
  # ubuntu related
  local gsettings_opts
  # macos related
  local osascript_opts

  # if ubuntu, use gsettings
  if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
    gsettings_opts="org.gnome.desktop.background picture-uri"
    cmd::record "gsettings set" "${gsettings_opts}" "'""${background_path}""'"
    cmd::record "gsettings set" "${gsettings_opts}""-dark ""'""${background_path}""'"
  # if macos, use osascript
  elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    osascript_opts="tell application \"Finder\" to set desktop picture to POSIX file"
    osascript_opts="'"${osascript_opts}" \""${background_path}"\"'"
    msg::debug "${osascript_opts}"
    cmd::record "osascript -e "${osascript_opts}""
  fi
}

#######################################
# Find a local background and save it
# Arguments:
#   $1 # a background path
#   $2 # absolute path
#######################################
loco::get_background_path(){
  local bg_path="${1-}"
  local ab_path="${2-}"
  local img_basename
  local img_path

  # copy option background in src/assets/backgrounds/
  _cp "${bg_path}" "src/assets/backgrounds/"

  # get filename from path
  img_basename=$(utils::string_cut_rev "${bg_path}" "/" "1")
  img_path="${ab_path}/src/assets/backgrounds/${img_basename}"

  _echo "${img_path}"
}

#######################################
# Download a background and save it
# Arguments:
#   $1 # a background url
#   $2 # absolute path
#######################################
loco::get_background_url(){
  local bg_url="${1-}"
  local ab_path="${2-}"
  local domain_name
  local img_basename
  local img_path

  # clean file name from URI encoded characters
  img_basename=$(basename "${bg_url}")
  # domain_name=$(_echo "${bg_url}" | awk -F/ '{print $3}')
  domain_name=$(utils::get_url_domain "${bg_url}")
  # if the image comes from duckduckgo images
  if [[ "${domain_name}" == *"duckduckgo.com" ]]; then
    msg::print "Duckduckgo images can be unstable."
    img_path=$(loco::get_duckduckgo_image "${bg_url}")
  # else if the image comes from an other domain
  else
    # download image
    utils::get_url "./src/assets/backgrounds" "${bg_url}"
    img_basename=$(utils::decode_URI "${img_basename}")
    img_path="${ab_path}/src/assets/backgrounds/${img_basename}"
  fi

  _echo "${img_path}"
}

#######################################
# Find the current background and save it
# GLOBALS:
#   LOCO_OSTYPE
#   INSTANCE_YAML
#######################################
loco::get_current_background(){
  local legacy_bg=$(yaml::get "${INSTANCE_YAML}" ".style.legacy_background")
  local loco_backgrounds_path="src/assets/backgrounds/"
  local background_path
  # ubuntu related
  local gsettings_opts
  # macos related
  local osascript_opts

  if [[ -n "${legacy_bg}" ]]; then
    msg::debug "Legacy background already exists."
  else
    # if ubuntu, use gsettings
    if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
      gsettings_opts="org.gnome.desktop.background picture-uri"
      background_path=$(cmd::run_as_user gsettings get "${gsettings_opts}")
      # remove the "file://"" uri prefix
      background_path=${background_path//\'/}
      background_path=${background_path#file://}
      # remove the opening and closing single quotes

    # if macos, use osascript
    elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
      osascript_opts="tell application \"Finder\" to get posix path of (get desktop picture as alias)"
      msg::debug "${osascript_opts}"
      background_path=$(cmd::run_as_user osascript -e "${osascript_opts}")
    fi
    # write legacy background path to yaml
    yaml::change "${INSTANCE_YAML}" ".style.legacy_background" "${background_path}"
  fi
}

#######################################
# Download a duckduckgo image
# note : very unstable due to duckduckgo path rewrite
# GLOBALS:
#   LOCO_OSTYPE
# Arguments:
#   $1 # a duckduckgo image url 
#######################################
loco::get_duckduckgo_image(){
  local bg_url="${1-}"
  local img_basename=$(basename "${bg_url}")
  local default_bg_url="christoph-von-gellhorn@unsplash.com.jpg"
  local ab_path=$(pwd)
  local img_path

  if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    msg::print "Duckduckgo images are not supported over macOS."
    msg::print "Downgrading to custom default background."

    # find base name to get exact filename and path
    img_path="${ab_path}"/src/assets/backgrounds/"${default_bg_url}"

  else
    # this substitution is meant fo correct `wget` colon substitution in sub-URLs
    img_basename="${img_basename/"%3A"/":"}"
    # if the picture sub-URL has its own encoded parameters
    if [[ "${bg_url}" == *"%3F"* ]]; then
      # substitution to find the sub-URL
      img_basename="${img_basename/"%3F"/"?"}"
      # get the first part of the uri
      # uri_first_part=$( _echo "${img_basename}" | cut -d'?' -f2 )
      uri_first_part=$(utils::string_cut "${img_basename}" "?" "2")
      # get the second part of the uri (which is encoded)
      # uri_second_part=$( _echo "${img_basename}" | cut -d'?' -f3 )
      uri_second_part=$(utils::string_cut "${img_basename}" "?" "3")
      # decodes the second part
      uri_second_part=$( utils::decode_URI "${uri_second_part}" )
      # rebuilds pathname
      img_basename="?""${uri_first_part}"?"${uri_second_part}"
    fi

    # download image
    utils::get_url "./src/assets/backgrounds" "${bg_url}"
    # find ase name to get exact filename and path
    img_basename=$(find "src/assets/backgrounds/" -name "*${img_basename}")
    img_path="${ab_path}"/"${img_basename}"
  fi

  _echo "${img_path}"
}
