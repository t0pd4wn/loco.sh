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
#   styles_fonts ? global
# Output:
#   /home/$USER/.fonts/[fonts]
#######################################
loco::fonts_manager(){
  local font
  local yaml_fonts="${style_fonts_urls-}"
  local assets_fonts=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/
  local fonts_path=/home/"${CURRENT_USER}"/.fonts
  # check for yaml fonts
  if [[ -z "${yaml_fonts}" ]]; then
    msg::print "No YAML fonts found"
  else 
    # iterate over the yaml array 
    IFS=' ' read -r -a fonts_array <<< "${yaml_fonts}"  
    for i in "${fonts_array[@]}"; do
      font=${!i}

      # install yaml fonts
      if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then


      # remove yaml fonts
      elif [[ "${ACTION}" == "remove" ]]; then
        IFS='/' read -r -a font_path <<< "${font}"
        local font_name=${font_path[-1]}
        msg::debug "${font_name}"
        # get clean system path
        local font_name_clean=$(printf "%b\n" "${font_name//%/\\x}")
        msg::debug "${font_name_clean}"
        local font_path="${fonts_path}"/"${font_name_clean}"
        utils::remove ${font_path}
        cmd::run_as_user "fc-cache -fr ""${fonts_path}"
      fi
    done
  fi

  # check for /assets/fonts/ fonts
  if [[ -z "$(ls -A "${assets_fonts}" 2>/dev/null)" ]]; then
    msg::print "No fonts found in /assets/fonts/."
  else

    # install local fonts
    if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
      utils::mkdir "${fonts_path}"
      local from_path=./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts/*
      local dest_path="${fonts_path}"
      utils::cp "${from_path}" "${dest_path}"

    # remove local fonts
    elif [[ "${ACTION}" == "remove" ]]; then
      # get a list of fonts as a bash array
      utils::list "fonts" "./"${PROFILES_DIR}"/"${PROFILE}"/assets/fonts"
      # loop over the local fonts list
      for font in "${fonts[@]}"; do
        local font_name_clean=$(printf "%b\n" "${font//%/\\x}")
        msg::debug "${font_name_clean}"
        local font_path="${fonts_path}"/"${font_name_clean}"
        # if the file exist, remove it
        if [[ ! -f "${font_path}" ]]; then
            msg::debug "Font not found."
          else 
            utils::remove "${font_path}"
        fi
      done
    fi
  fi
}

loco::fonts_action_install_yaml(){
          utils::mkdir "${fonts_path}"
        utils::get_url "${fonts_path}" "${font}"
        # refresh fonts cache
        cmd::run_as_user "fc-cache -fr ""${fonts_path}"
}

loco::fonts_action_remove_yaml(){
          utils::mkdir "${fonts_path}"
        utils::get_url "${fonts_path}" "${font}"
        # refresh fonts cache
        cmd::run_as_user "fc-cache -fr ""${fonts_path}"
}