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
install_ubuntu_custom_exit(){
  su "${CURRENT_USER}" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
  # launch zsh, could be automated further
  msg::record 'type `zsh` to init your zsh prompt'
}

remove_ubuntu_custom_exit(){
  # launch bash, could be automated further
  msg::record 'type `bash` to init your zsh prompt'
}