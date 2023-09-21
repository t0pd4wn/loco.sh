#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | profile custom functions (execute as root)
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

remove_exit(){
  # remove vim bundles
  utils::remove /home/${CURRENT_USER}/.vim/bundle/anyfold
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-airline
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-airline-themes
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-line-no-indicator
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-minimap
  utils::remove /home/${CURRENT_USER}/.vim/bundle/vim-monokai
  utils::remove /home/${CURRENT_USER}/.vim/bundle/Vundle.vim  
}