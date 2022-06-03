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
  # note : as ubuntu 21.04 neovim is not installed as default
  # removes neovim if present
  # if eval 'command -v nvim' > /dev/null 2>&1; then
  #   msg::prompt "Remove Neovim (y/n)"
  #   case ${USER_ANSWER:0:1} in
  #   y|Y )
  #       msg::say "${EMOJI_YES}" " Yes, remove Neovim."
  #       sudo apt --yes remove neovim
  #       msg::record "Neovim has been removed"
  #   ;;
  #   * )
  #     msg::say "${EMOJI_NO}" " No, I'll keep Neovim."
  #     exit;
  #   ;;
  #   esac
  # else
  #   msg::say "" "Neovim is not installed."
  # fi
}

install_ubuntu_custom_exit(){
  # download vundle
  sudo rm -fR /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim
  cmd::run_as_user "git clone https://github.com/VundleVim/Vundle.vim.git /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"
  # install vundle plugins
  cmd::run_as_user "vim +PluginInstall +qall"
}

remove_ubuntu_custom_entry(){
  # note : as ubuntu 21.04 neovim is not installed as default
  # reinstalls neovim
  # sudo apt --yes install neovim
  # msg::record 'Neovim has been reinstalled'
}

