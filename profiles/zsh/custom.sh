#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | profile custom functions (execute as root)
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # install powerlevel10K
  cmd::run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/"${CURRENT_USER}"/.zsh-plugins/powerlevel10k"
}

remove_exit(){
  # remove powerlevel10K
  utils::remove "/home/${CURRENT_USER}/.zsh-plugins/powerlevel10k"
}