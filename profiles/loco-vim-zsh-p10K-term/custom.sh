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
<<<<<<< HEAD
  sudo rm -fR /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim
=======
  sudo rm -R /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim
>>>>>>> c49ca10 (Dev)
  su "${CURRENT_USER}" -c "git clone https://github.com/VundleVim/Vundle.vim.git /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"
  # install vundle plugins
  su "${CURRENT_USER}" -c "vim +PluginInstall +qall"
  # install powerlevel10K
<<<<<<< HEAD
  sudo rm -fR /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k
=======
  sudo rm -R /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k
>>>>>>> c49ca10 (Dev)
  su "${CURRENT_USER}" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
  # launch zsh, could be automated further
  msg::record 'type `zsh` to init your zsh prompt'
}

remove_ubuntu_custom_entry(){
  # reinstalls neovim 
  sudo apt --yes install neovim
  msg::record 'Neovim has been reinstalled'
}

remove_ubuntu_custom_exit(){
  # launch bash, could be automated further
  msg::record 'type `bash` to init your zsh prompt'
}