#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# ubuntu related
#################
install_ubuntu_exit(){
  # set ubuntu 21.04 and above dock style
  if [[ "${SHORT_OS_VERSION}" -ge 21 ]]; then
    cmd::record "gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true;"
    cmd::record "gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5750;"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false;"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM;"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 60;"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true"
    # cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
  fi
  # set ubuntu folders style
  cmd::record "gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view';"
  cmd::record "gsettings set org.gnome.nautilus.list-view use-tree-view true;"
  cmd::record "gsettings set org.gnome.nautilus.preferences default-sort-order 'type';"
}

remove_ubuntu_exit(){
  # reset ubuntu 21.04 and above default dock style
  if [[ "${SHORT_OS_VERSION}" -ge 21 ]]; then
    cmd::record "gsettings reset org.gnome.settings-daemon.plugins.color night-light-enabled;"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock extend-height;"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dock-position;"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size;"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock autohide;"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock intellihide;"
    # cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dock-fixed;"
  fi
  # reset ubuntu folders style
  cmd::record "gsettings reset org.gnome.nautilus.preferences default-folder-viewer;"
  cmd::record "gsettings reset org.gnome.nautilus.list-view use-tree-view;"
  cmd::record "gsettings reset org.gnome.nautilus.preferences default-sort-order;"
}