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
  local custom_default_bg_url="https://raw.githubusercontent.com/t0pd4wn/loco.sh/gh-main/src/backgrounds/christoph-von-gellhorn@unsplash.com.jpg"
  local profile_bg_path=$(find "${ab_path}"/"${assets_path}" -name 'background.*' 2>/dev/null)
  local yaml_bg_url=$(utils::yaml_get_values '.style.background')
  local bg_url="${BACKGROUND_URL:-"${yaml_bg_url}"}"
  local local_bgs_path=./src/backgrounds/
  local img_basename
  local domain_name
  local uri_first_part
  local uri_second_part
  local final_path

  # meant to restore default OS values
  local os_default_bg
  local os_path

  # if action is install
  if [[ "${ACTION}" == "install" ]] ||[[ "${ACTION}" == "update" ]]; then
    # if a background url option is set through -B or profile.yaml
    if [[ ! -z "${bg_url}" ]]; then
      msg::print "Background url option found."

      # clean file name from URI encoded characters
      img_basename=$(basename "${bg_url}")

      # warning : below code is meant to support duckduckgo images
      # there are few problems related to URLs special characters decoding 
      # as duckduckgo proxies original URLs which can include sub-URLs
      # it is hard to get the correct path to install them dynamically
      local domain_name=$( utils::echo "${bg_url}" | awk -F/ '{print $3}')

      # if the image comes from duckduckgo images
      if [[ "${domain_name}" == *"duckduckgo.com" ]]; then
        msg::print "Duckduckgo images can be unstable."
        if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
          msg::print "Duckduckgo images are not supported over macOS."
          msg::print "Downgrading to custom default background."
          # download image
          utils::get_url "./src/backgrounds" "${custom_default_bg_url}"
          # find ase name to get exact filename and path
          img_basename=$(find "src/backgrounds/" -name "*${img_basename}")
          final_path="${ab_path}"/"${img_basename}"
        else
          # this substitution is meant fo correct `wget` colon substitution in sub-URLs
          img_basename="${img_basename/"%3A"/":"}"  

          msg::debug ${img_basename}  

          # if the picture sub-URL has its own encoded parameters
          if [[ "${bg_url}" == *"%3F"* ]]; then
            # substitution to find the sub-URL
            img_basename="${img_basename/"%3F"/"?"}"
            # get the first part of the uri
            uri_first_part=$( utils::echo "${img_basename}" | cut -d'?' -f2 )
            # get the second part of the uri (which is encoded)
            uri_second_part=$( utils::echo "${img_basename}" | cut -d'?' -f3 )
            # decodes the second part
            uri_second_part=$( utils::decode_URI "${uri_second_part}" )
            # rebuilds pathname
            img_basename="?""${uri_first_part}"?"${uri_second_part}"
          fi
          
          # download image
          utils::get_url "./src/backgrounds" "${bg_url}"
          # find ase name to get exact filename and path
          img_basename=$(find "src/backgrounds/" -name "*${img_basename}")
          final_path="${ab_path}"/"${img_basename}"
        fi

      # else if the image comes from an other domain
      else
        # download image
        utils::get_url "./src/backgrounds" "${bg_url}"
        img_basename=$( utils::decode_URI "${img_basename}" )
        final_path="${ab_path}"/src/backgrounds/"${img_basename}"
      fi

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
      os_default_bg="warty-final-ubuntu.png"
      os_path=/usr/share/backgrounds/
      final_path="${os_path}""${os_default_bg}"
    elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
      os_default_bg="Monterey Graphic.heic"
      os_path="/System/Library/Desktop Pictures/"
      final_path="${os_path}""${os_default_bg}"
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
# GLOBALS:
#   LOCO_OSTYPE
#   SHORT_OS_VERSION
# Arguments:
#   $1 // a background uri 
#######################################
loco::set_background(){
  local background_path="${@-}"
  # ubuntu related
  local gsettings_opts
  # macos related
  local osascript_opts

  # if ubuntu, use gsettings
  if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
    gsettings_opts="org.gnome.desktop.background picture-uri"
    cmd::record "gsettings set" "${gsettings_opts}" "'""${background_path}""'"
    if [[ "${SHORT_OS_VERSION}" == "22" ]]; then
      cmd::record "gsettings set" "${gsettings_opts}""-dark ""'""${background_path}""'"
    fi
  # if macos, use osascript
  elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    osascript_opts="tell application \"Finder\" to set desktop picture to POSIX file"
    osascript_opts="'"${osascript_opts}" \""${background_path}"\"'"
    msg::debug "${osascript_opts}"
    cmd::record "osascript -e "${osascript_opts}""
  fi
}