#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # download vundle
  cmd::run_as_user "git clone https://github.com/VundleVim/Vundle.vim.git /"${OS_PREFIX}"/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"

  # install vundle plugins
  cmd::run_as_user "vim +PluginInstall +qall"

  # install powerlevel10K
  # utils::remove "/home/${CURRENT_USER}/.zsh-plugins/powerlevel10k"
  cmd::run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /"${OS_PREFIX}"/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

remove_exit(){
  # remove vim bundles
  utils::remove "/"${OS_PREFIX}"/"${CURRENT_USER}"/.vim/bundle/*"

  # remove powerlevel10K
  utils::remove "/"${OS_PREFIX}"/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

#################
# macosx related
#################
install_macos_exit(){
  # display only active apps
  cmd::record "defaults write com.apple.dock static-only -bool TRUE; killall Dock"
  # activate menu bar autohide
  cmd::record "defaults write NSGlobalDomain _HIHideMenuBar -bool TRUE; killall Finder"
  # activate dock autohide
  cmd::record "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'"
}

remove_macos_exit(){
  # display all apps
  cmd::record "defaults write com.apple.dock static-only -bool FALSE; killall Dock"
  # deactivate menu bar autohide
  cmd::record "defaults write NSGlobalDomain _HIHideMenuBar -bool FALSE; killall Finder"
  # deactivate dock autohide
  cmd::record "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to false'"
}

#################
# ubuntu related
#################
install_ubuntu_exit(){
  # set ubuntu 22.04 custom dock style
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
  # set ubuntu folders style
  cmd::record "gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view';"
  cmd::record "gsettings set org.gnome.nautilus.list-view use-tree-view true;"
  cmd::record "gsettings set org.gnome.nautilus.preferences default-sort-order 'type';"
}

remove_ubuntu_exit(){
  # set ubuntu 22.04 default dock style
  if [[ "${SHORT_OS_VERSION}" == "21" ]] || [[ "${SHORT_OS_VERSION}" == "22" ]]; then
    cmd::record "gsettings reset org.gnome.settings-daemon.plugins.color night-light-enabled"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock extend-height"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dock-position"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock autohide"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock dock-fixed"
    cmd::record "gsettings reset org.gnome.shell.extensions.dash-to-dock intellihide"
  fi
  # reset ubuntu folders style
  cmd::record "gsettings reset org.gnome.nautilus.preferences default-folder-viewer;"
  cmd::record "gsettings reset org.gnome.nautilus.list-view use-tree-view;"
  cmd::record "gsettings reset org.gnome.nautilus.preferences default-sort-order;"
}