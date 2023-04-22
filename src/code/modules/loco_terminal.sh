#!/bin/bash
#-------------------------------------------------------------------------------
# loco_terminal.sh | loco.sh terminal functions
#-------------------------------------------------------------------------------

#######################################
# Manage terminal style actions.
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
# Print the dconf configuration command in finish.sh
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
# Ref : https://www.linuxshelltips.com/export-import-gnome-terminal-profile/
# GLOBALS:
#   PROFILES
#   PROFILES_DIR
#   LOCO_DIST
#   THEME
#######################################
loco::term_conf_set(){
  # check if current loco is a remote installation
  if [[ "${LOCO_DIST}" == true ]]; then local dist_path=loco-dist/; fi

  # instanciate yaml values or global/default ones
  local font_name
  local font_size

  # macos related
  local osascript_opt
  local osascript_fontname
  local osascript_fontsize
  local content
  local file

  local colors_theme_file=./src/assets/themes/"${THEME}".conf

  font_name=$(yaml::get_child_values '.style.fonts.name')
  if [[ "${ACTION}" == "install" ]] || [[ "${ACTION}" == "update" ]]; then
    #statements
    font_name="${font_name}"
  elif [[ "${ACTION}" == "remove" ]]; then
    if [[ "${LOCO_OSTYPE}" == "ubuntu" ]]; then
      font_name="${"Monospace"}"
    elif [[ "${LOCO_OSTYPE}" == "macos" ]]; then
      font_name="${"SF Mono"}"
    fi
  fi

  font_size=$(yaml::get_child_values '.style.fonts.size')
  font_size="${font_size:-"10"}"

  if [[ "${LOCO_OSTYPE}" == "macos" ]]; then
    osascript_opt="tell application \"Terminal\" to set the font "
    osascript_fontname="name of window 1 to \""${font_name}"\""
    osascript_fontname="osascript -e '"${osascript_opt}""${osascript_fontname}"'"
    osascript_fontsize="size of window 1 to \""${font_size}"\""
    osascript_fontsize="osascript -e '"${osascript_opt}""${osascript_fontsize}"'"
    cmd::record "${osascript_fontname}"
    cmd::record "${osascript_fontsize}"

    # doublon because perl needs a specific syntax
    single_quote="\x27"
    double_quote="\x22"
    line_carriage="\n"
    osa_opt='tell application '"${double_quote}"'Terminal'"${double_quote}"' to set the font '
    osa_fontname='name of window 1 to '"${double_quote}""${font_name}""${double_quote}"
    osa_fontname='  osascript -e '"${single_quote}""${osa_opt}""${osa_fontname}""${single_quote}"
    osa_fontsize='size of window 1 to \"'"${font_size}"'\"'
    osa_fontsize='  osascript -e '"${single_quote}""${osa_opt}""${osa_fontsize}""${single_quote}"

    # write osascript commands to .zprofile to make them persistent
    content="${osa_fontname}""${line_carriage}""${osa_fontsize}"
    content='### MacOS font setup'"${line_carriage}""${content}""${line_carriage}"'  ###'
    file='./'"${PROFILES_DIR}"/"${PROFILE}"'/dotfiles/.zprofile'

    # find the block of text in .zprofile and replace it
    utils::replace_block_in_file "### MacOS font" "###" "${content}" "${file}"
    
    # as terminal configuration is limited over macosx, end here
    return 0
  fi

  # local /assets/terminal.conf file
  local local_theme=./"${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  # local distro_theme=./"${dist_path-}""${PROFILES_DIR}"/"${PROFILE}"/assets/terminal.conf
  
  # gnome related paths and infos
  local gnome_path="/org/gnome/terminal/legacy/profiles:/"
  local gnome_UUID="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"

  local local_path
  local distro_path

  # check if a terminal configuration is present, if not prepare one
  if [[ ! -f "${local_theme}" ]]; then
    msg::print "No terminal configuration file found"


    local_path=./src/temp/"${PROFILE}"_terminal.conf
    # distro_path=./"${dist_path-}"src/temp/"${PROFILE}"_terminal.conf

    # if there is a colors theme set, build the conf file
    if [[ ! -z "${THEME}" ]]; then
      _echo "[/]" > "${local_path}"
      _cat "${colors_theme_file}" >> "${local_path}"
      # for some reasons, an extra "\n" needs to be applied here
      if [[ ! -z "${font_name}" ]]; then
        _echo "\n""font='"${font_name}" "${font_size}"'" >> "${local_path}"
        _echo "use-system-font=false" >> "${local_path}"
        yaml::change "${INSTANCE_YAML}" ".style.fonts.name" "${font_name}"
        yaml::change "${INSTANCE_YAML}" ".style.fonts.size" "${font_size}"
      else
        _echo "\n""use-system-font=false" >> "${local_path}"
      fi
      
      _echo "use-theme-colors=false" >> "${local_path}"
      _echo "use-theme-transparency=false" >> "${local_path}"
      _echo "use-transparent-background=true" >> "${local_path}"
      _echo "bold-color-same-as-fg=false" >> "${local_path}"
      _echo "visible-name='loco-profile'" >> "${local_path}"
      loco::term_conf_record_command "${gnome_path}" "${gnome_UUID}" "${local_path}"
    fi
  # only supported over ubuntu
  else
    msg::say "Using /assets/terminal.conf file"
    loco::term_conf_record_command "${gnome_path}" "${gnome_UUID}" "${local_theme}"
  fi



}