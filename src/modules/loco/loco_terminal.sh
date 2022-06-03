#!/bin/bash
#-------------------------------------------------------------------------------
# loco_terminal.sh | loco.sh terminal functions
#-------------------------------------------------------------------------------

#######################################
# Build terminal style file.
# note : Setting dconf for a specific user thorugh terminal,
# can only be achieved with root rights (su, not sudo).
# GLOBALS:
#   PROFILES
#   PROFILES_DIR
#   ACTION
#   LOCO_DIST
#######################################
loco::term_conf_manager(){
  local gnome_path="/org/gnome/terminal/legacy/profiles:/"

  # if action is install or update
  if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
    # create the terminal.conf file
    loco::term_conf_set

  # if action is remove
  elif [[ "${ACTION}" == "remove" ]]; then
    # prepare the command line for resetting profile
    loco::term_conf_record_command "${gnome_path}" 
  fi
}

#######################################
# Print the dconf configuration command
# note : scheme to dump profile
# dconf list /org/gnome/terminal/legacy/profiles:/
# dconf dump /org/gnome/terminal/legacy/profiles:/:[profile id]
#   $1 // dconf gnome path
#   $2 // dconf gnome UUID
#   $3 // terminal.conf file
#######################################
loco::term_conf_record_command(){
  local gnome_path="${1-}"
  local gnome_UUID="${2-}"
  local distro_path="${3-}"

  if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
    cmd::record "dconf load "${gnome_path}":"${gnome_UUID}"/ < ""${distro_path}"
  elif [[ "${ACTION}" == "remove" ]]; then
    cmd::record "dconf reset -f "${gnome_path}""
  fi
}

#######################################
# Build terminal style file.
# note : Setting dconf for a specific user thorugh terminal,
# can only be achieved with root rights (su, not sudo).
# GLOBALS:
#   PROFILES
#   PROFILES_DIR
#   LOCO_DIST
#######################################
loco::term_conf_set(){
  # check if current loco is a remote installation
  if [[ "${LOCO_DIST}" == true ]]; then local dist_path=loco-dist/; fi

  # instanciate yaml values or global/default ones
  local colors_theme
  local font_name
  local font_size

  colors_theme=$(utils::yaml_get_values '.style.colors.theme')
  colors_theme="${THEME:-"${colors_theme}"}"

  local colors_theme_file=./src/themes/"${colors_theme}".conf
  
  font_name=$(utils::yaml_get_values '.style.fonts.name')
  if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
    #statements
    font_name="${font_name}"
  elif [[ "${ACTION}" == "remove" ]]; then
    font_name="${"Monospace"}"
  fi

  font_size=$(utils::yaml_get_values '.style.fonts.size')
  font_size="${font_size:-"11"}"

  # local /assets/terminal.conf file
  local local_theme=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  local distro_theme=./"${dist_path-}""${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  
  # gnome related paths and infos
  local gnome_path="/org/gnome/terminal/legacy/profiles:/"
  local gnome_UUID="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"

  local local_path
  local distro_path

  # check if a terminal configuration is present, if not prepare one
  if [[ ! -f "${local_theme}" ]]; then
    msg::debug "No terminal configuration file found"

    local_path=./src/temp/"${PROFILE}"_terminal.conf
    distro_path=./"${dist_path-}"src/temp/"${PROFILE}"_terminal.conf

    # if there is a colors theme set, build the conf file
    if [[ ! -z "${colors_theme}" ]]; then
      utils::echo "[/]" > "${local_path}"
      cat "${colors_theme_file}" >> "${local_path}"
      # for some reasons, an extra "\n" needs to be applied here
      if [[ ! -z "${font_name}" ]]; then
        utils::echo "\n""font='"${font_name}" "${font_size}"'" >> "${local_path}"
        utils::echo "use-system-font=false" >> "${local_path}"
      else
        utils::echo "\n""use-system-font=false" >> "${local_path}"
      fi
      
      utils::echo "use-theme-colors=false" >> "${local_path}"
      utils::echo "use-theme-transparency=false" >> "${local_path}"
      utils::echo "use-transparent-background=true" >> "${local_path}"
      utils::echo "bold-color-same-as-fg=false" >> "${local_path}"
      utils::echo "visible-name='loco-profile'" >> "${local_path}"
      loco::term_conf_record_command "${gnome_path}" "${gnome_UUID}" "${distro_path}"
    fi
  else
    msg::say "Using /assets/terminal.conf file"
    loco::term_conf_record_command "${gnome_path}" "${gnome_UUID}" "${distro_path}"
  fi
}