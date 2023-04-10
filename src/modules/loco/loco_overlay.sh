#!/bin/bash
#-------------------------------------------------------------------------------
# loco_background.sh | loco.sh background functions
#-------------------------------------------------------------------------------

#######################################
# Prepare custom functions execution
# GLOBALS:
#   ACTION
#   OVERLAY_PATH
#   PROFILE
#   PROFILES_DIR
# Arguments:
#   $1 # the background path
#######################################
loco::overlay_manager(){
  local bg_path="${1-}"

  local custom_default_bg_url="https://raw.githubusercontent.com/t0pd4wn/loco.sh/gh-main/src/backgrounds/christoph-von-gellhorn@unsplash.com.jpg"
  local ab_path=$(pwd)
  local assets_path="${PROFILES_DIR}"/"${PROFILE}"/assets/
  local profile_ovl_path=$(find "${ab_path}"/"${assets_path}" -name 'overlay.png' 2>/dev/null)
  local yaml_ovl_path=$(utils::yq_get "${PROFILE_YAML}" '.style.overlay')
  local ovl_path="${OVERLAY_PATH:-"${yaml_ovl_path}"}"
  local local_ovls_path=./src/background-overlays/
  local final_path

  # if action is install
  if [[ "${ACTION}" == "install" ]] ||[[ "${ACTION}" == "update" ]]; then

    # if a background url option is set through -B or profile.yaml
    if [[ ! -z "${ovl_path}" ]]; then
      msg::print "Overlay path is specified."
      final_path="${ovl_path}"
      msg::debug "${final_path}"
    # else, if an overlay file is present in /assets/
    elif [[ -f "${profile_ovl_path}" ]]; then
      msg::print "Overlay file found in assets."
      final_path="${profile_ovl_path}"
      msg::debug "${final_path}"
    # else, if background(s) file(s) are present in /src/backgrounds
    elif [[ ! -z "$(ls -A "${local_ovls_path}" 2>/dev/null)" ]]; then
      msg::print "Overlay files found in /src/background-overlays/."
      # launch a prompt to select background
      loco::prompt_overlay
      # 
      final_path="${OVERLAY_PATH}"
      final_path=$( find "${ab_path}""/src/background-overlays" -name "${OVERLAY_PATH}.png" )
    fi
  fi

  msg::debug "${final_path-}"

  # if an overlay has been selected
  if [[ ! -z "${final_path-}" ]]; then
    # send the image path to config file
    loco::apply_overlay "${final_path}" "${bg_path}"
  # if not
  else
    # send only the background to conf file
    loco::set_background "${bg_path}"
  fi
}

#######################################
# Apply an overlay to an image
# Arguments:
#   $1 // a trnasparent overlay path
#   $1 // a background path
#######################################
loco::apply_overlay(){
  local ovl_path="${1-}"
  local bg_path="${2-}"

  local ab_path=$(pwd)
  local bg_basename
  local ovl_basename
  local output_name
  local output_path

  # background name
  bg_basename=$(basename "${bg_path}")
  ovl_basename=$(basename "${ovl_path}")

  # output name
  output_name="${bg_basename}""_""${ovl_basename}"".jpg"
  output_path="${ab_path}""/src/backgrounds/""${output_name}"

  # apply overlay to background
  utils::image_overlay "${bg_path}" "${ovl_path}" "${output_path}"

  # copy new background path to config file
  loco::set_background "${output_path}"
}