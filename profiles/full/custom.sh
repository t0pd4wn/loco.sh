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
  
  # set vpn icon for p10k.zsh
  cmd::run_as_user "sed -i '/# vpn_ip/c\vpn_ip' ~/.p10k.zsh"
}

remove_exit(){
  # remove vim bundles
  utils::remove /home/${CURRENT_USER}/.vim/bundle/anyfold
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-airline
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-airline-themes
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-line-no-indicator
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-minimap
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-monokai
  utils::remove /home/${CURRENT_USER}/.vim/bundle/Vundle.vim  
  # unset vpn icon for p10k.zsh
  cmd::run_as_user "sed -i '/vpn_ip/c\# vpn_ip' ~/.p10k.zsh"

  # remove powerlevel10K
  utils::remove "/"${OS_PREFIX}"/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

#################
# macOS related
#################
install_macos_exit(){
  set_macos_style
}

update_macos_exit(){
  set_macos_style
}

remove_macos_exit(){
  unset_macos_style
}

#################
# ubuntu related
#################
install_ubuntu_exit(){
  set_ubuntu_style
}

update_ubuntu_exit(){
  set_ubuntu_style
}

remove_ubuntu_exit(){
  unset_ubuntu_style
}

#################
# Custom functions
#################
set_ubuntu_style(){
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

unset_ubuntu_style(){
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

set_macos_style(){
  # display only active apps
  cmd::record "defaults write com.apple.dock static-only -bool TRUE; killall Dock"
  # activate menu bar autohide
  cmd::record "defaults write NSGlobalDomain _HIHideMenuBar -bool TRUE; killall Finder"
  # activate dock autohide
  cmd::record "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'"
  # deactivate bash sessions
  cmd::record "defaults write com.apple.Terminal NSQuitAlwaysKeepsWindows -bool false"
  # correct macOS POSIX behavior by enabling the sourcing of .profile prior to .rc files
  cmd::record "env POSIX=$HOME/.profile /bin/sh"
}

unset_macos_style(){
  # display all apps
  cmd::record "defaults write com.apple.dock static-only -bool FALSE; killall Dock"
  # reactivate menu bar autohide
  cmd::record "defaults write NSGlobalDomain _HIHideMenuBar -bool FALSE; killall Finder"
  # reactivate dock autohide
  cmd::record "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to false'"
  # reactivate bash sessions
  cmd::record "defaults write com.apple.Terminal NSQuitAlwaysKeepsWindows -bool true"
  # remove POSIX variable
  cmd::record "unset POSIX"
}
