#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

# macos related
install_macos_custom_entry(){
  # install homebrew if on macos
  if [[ "${LOCO_OSTYPE}" == "macos" ]];  then
      PACKAGE="brew"
      PACKAGE_ACTION_CMD='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      loco::meta_package "${PACKAGE}" "${PACKAGE_ACTION_CMD}"
  fi
}

# ubuntu related
install_ubuntu_custom_entry(){
  # since nvim is default on ubuntu, runs a check
  # removes neovim if present
  if eval 'command -v nvim' > /dev/null 2>&1; then
    msg::prompt "Remove Neovim (y/n)"
    case ${USER_ANSWER:0:1} in
    y|Y )
        msg::say "${EMOJI_YES}" " Yes, remove Neovim."
        sudo apt --yes remove neovim
        msg::record "Neovim has been removed"
    ;;
    * )
      msg::say "${EMOJI_NO}" " No, I'll keep Neovim."
      exit;
    ;;
    esac
  else
    msg::say "" "Neovim is not installed."
  fi
}

install_ubuntu_custom_exit(){
  # download vundle
  sudo rm -fR /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim
  cmd::run_as_user "git clone https://github.com/VundleVim/Vundle.vim.git /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"

  # install vundle plugins
  cmd::run_as_user "vim +PluginInstall +qall"
  # install powerlevel10K
  sudo rm -fR /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k
  cmd::run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
  # launch zsh, could be automated further
  # set ubuntu 22.04 dock style
  if [[ "$(lsb_release -r -s)" == "22.04" || "22.10" ]]; then
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true"
  fi
}

remove_ubuntu_custom_entry(){
  # reinstalls neovim 
  sudo apt --yes install neovim
  msg::record 'Neovim has been reinstalled'
}

remove_ubuntu_custom_exit(){
  # launch bash, could be automated further
  msg::record 'type `bash` to init your zsh prompt'
  if [[ "$(lsb_release -r -s)" == "22.04" || "22.10" ]]; then
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position LEFT"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock autohide false"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true"
    cmd::record "gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false"
  fi
}