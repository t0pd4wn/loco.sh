#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # download vundle
  # utils::remove "/home/${CURRENT_USER}/.vim/bundle/Vundle.vim"
  cmd::run_as_user "git clone https://github.com/VundleVim/Vundle.vim.git /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"

  # install vundle plugins
  cmd::run_as_user "vim +PluginInstall +qall"

  # install powerlevel10K
  # utils::remove "/home/${CURRENT_USER}/.zsh-plugins/powerlevel10k"
  cmd::run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

remove_exit(){
  # launch bash, could be automated further
  msg::record 'type `bash` to reset your prompt'

  # remove vim bundles
  utils::remove "/home/${CURRENT_USER}/.vim/bundle/*"

  # remove powerlevel10K
  utils::remove "/home/${CURRENT_USER}/.zsh-plugins/powerlevel10k"
}

#################
# ubuntu related
#################
install_ubuntu_exit(){
  # set ubuntu 22.04 custom dock style
  if [[ "${LOCO_OS_VERSION}" == "22.04" || "22.10" ]]; then
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
  if [[ "${LOCO_OS_VERSION}" == "22.04" || "22.10" ]]; then
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position LEFT"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false"
  fi
}