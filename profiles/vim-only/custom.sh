#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # download vundle
  utils::remove /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim
  cmd::run_as_user "git clone https://github.com/VundleVim/Vundle.vim.git /home/"${CURRENT_USER}"/.vim/bundle/Vundle.vim"
  # install vundle plugins
  cmd::run_as_user "vim +PluginInstall +qall"
}