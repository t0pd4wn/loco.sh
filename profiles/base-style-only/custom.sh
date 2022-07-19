#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# ubuntu related
#################
install_ubuntu_exit(){
  # set ubuntu custom dock style
  if [[ "${SHORT_OS_VERSION}" == "21" ]] || [[ "${SHORT_OS_VERSION}" == "22" ]]; then
    cmd::record "gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true"
    cmd::record "gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5750"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false"
  fi
}

remove_ubuntu_exit(){
  # set ubuntu default dock style
  if [[ "${SHORT_OS_VERSION}" == "21" ]] || [[ "${SHORT_OS_VERSION}" == "22" ]]; then
    cmd::record "gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position LEFT"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false"
  fi
}
