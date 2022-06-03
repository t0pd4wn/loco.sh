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
  local file_path=$(find "${ab_path}"/"${assets_path}" -name 'background.*')
  local yaml_file_path="${style_background-}"
  local local_files_path=./src/backgrounds/
  local img_name
  local final_path

  # if no background url option is set
  if [[ -z "${BACKGROUND_URL}" ]]; then
    msg::debug "No background url option set."
    # if no background file is present in /assets/
    if [[ ! -f "${file_path}" ]]; then
      msg::debug "No local assets background."
      # if no background url is present in the yaml file
      if [[ -z "${yaml_file_path}" ]]; then
        msg::debug "No yaml background url."
        # if no background(s) file(s) are present in /src/backgrounds
        if [[ -z "$(ls -A "${local_files_path}" 2>/dev/null)" ]]; then
          msg::debug "No backgrounds found in /src/backgrounds/." 

        # 3. if background(s) file(s) are present in /src/backgrounds
        else
          msg::debug "Backgrounds found in /src/backgrounds/."
          loco::prompt_background
          msg::debug "${ab_path}""/src/backgrounds"
          final_path=$(find "${ab_path}""/src/backgrounds" -name "${BACKGROUND}.*")
        fi  

      # 2. if a background file is present in the yaml file
      else
        msg::debug "Yaml background url found."
        utils::get_url "./src/backgrounds" "${yaml_file_path}"
        img_name=$(basename "${yaml_file_path}")
        final_path=$(find "${ab_path}""/src/backgrounds" -name "${img_name}")
      fi  

    # 1. if a background file is present in /assets/
    else
      msg::debug "Local assets background found."
      final_path="${file_path}"
    fi
    
  # 0. if a background url option is set
  else 
    msg::debug "Background url option found."
    utils::get_url "./src/backgrounds" "${BACKGROUND_URL}"
    img_name=$(basename "${BACKGROUND_URL}")
    final_path=$(find "${ab_path}""/src/backgrounds" -name "${img_name}")
  fi

  msg::debug "${final_path-}"
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
  cmd::record "gsettings set "${gsettings_opts}" "${background_path}""
  if [[ "$(lsb_release -r -s)" == "22.04" || "22.10" ]]; then
    cmd::record "gsettings set "${gsettings_opts}"-dark "${background_path}""
  fi
}