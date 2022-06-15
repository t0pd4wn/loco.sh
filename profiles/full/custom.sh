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

# # insert commands below# move to bottom
# defaults write com.apple.dock orientation bottom# move to left
# defaults write com.apple.dock orientation left# move to right
# defaults write com.apple.dock orientation right#restart Dock
# killall Dock
#################
# macosx related
#################
install_macos_exit(){
  # display only active apps
  cmd::record "defaults write com.apple.dock static-only -bool TRUE; killall Dock"
}

remove_macos_exit(){
  # display all apps
  cmd::record "defaults write com.apple.dock static-only -bool FALSE; killall Dock"
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
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true"
  fi
}

remove_ubuntu_exit(){
  # set ubuntu 22.04 default dock style
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