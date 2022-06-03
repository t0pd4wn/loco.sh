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
loco::term_conf_set(){
  # check if current loco is a remote installation
  if [[ "${LOCO_DIST}" == true ]]; then local dist_path=loco-dist/; fi
  local local_path=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  local distro_path=./"${dist_path-}""${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  local gnome_path="/org/gnome/terminal/legacy/profiles:/"
  local gnome_UUID="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"

  # check if a terminal configuration is present, if not prepare one
  if [[ ! -f "${local_path}" ]]; then
    local_path=./src/temp/"${PROFILE}"_terminal.conf
    distro_path=./"${dist_path-}"src/temp/"${PROFILE}"_terminal.conf
    msg::print "No terminal configuration file found"
    local colors_theme="${style_colors_theme-"${THEME}"}"
    local colors_theme_file=./src/themes/"${colors_theme}".conf
    local font_name="${style_fonts_name-Monospace}"
    local font_size="${style_fonts_size-11}"
    msg::debug "${style-}"
    msg::debug "${style_colors-}"
    msg::debug "${colors_theme-}"

    # if there is a colors theme set, build the conf file
    if [[ ! -z "${colors_theme}" ]]; then
      msg::debug "${colors_theme}"
      utils::echo "[/]" > "${local_path}"
      cat "${colors_theme_file}" >> "${local_path}"
      utils::echo "\n""font='"${font_name}" "${font_size}"'" >> "${local_path}"
      utils::echo "use-system-font=false" >> "${local_path}"
      utils::echo "use-theme-colors=false" >> "${local_path}"
      utils::echo "use-theme-transparency=false" >> "${local_path}"
      utils::echo "use-transparent-background=true" >> "${local_path}"
      utils::echo "bold-color-same-as-fg=false" >> "${local_path}"
      utils::echo "visible-name='loco-profile'" >> "${local_path}"
      loco::term_conf_action "${gnome_path}" "${gnome_UUID}" "${distro_path}"
    fi
  else
    loco::term_conf_action "${gnome_path}" "${gnome_UUID}" "${distro_path}"
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
loco::term_conf_action(){
  local gnome_path="${1-}"
  local gnome_UUID="${2-}"
  local distro_path="${3-}"
    # if yes, print command to install / remove it
  if [[ "${ACTION}" == "install" ]]; then
    cmd::record "dconf load "${gnome_path}":"${gnome_UUID}"/ < ""${distro_path}"
  elif [[ "${ACTION}" == "remove" ]]; then
    cmd::record "dconf reset -f "${gnome_path}""
  fi
}
