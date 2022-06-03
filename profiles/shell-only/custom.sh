#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_generic_exit(){
  # install powerlevel10K
  sudo rm -fR /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k
  cmd::run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

remove_generic_exit(){
  # launch bash, could be automated further
  msg::record 'type `bash` to reset your prompt'
}

#################
# macos related
#################
install_macos_entry(){
  # install homebrew if on macos
  if [[ "${LOCO_OSTYPE}" == "macos" ]];  then
    PACKAGE="brew"
    PACKAGE_ACTION_CMD='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    loco::meta_package "${PACKAGE}" "${PACKAGE_ACTION_CMD}"
  fi
}