#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # set vpn icon for p10k.zsh
  cmd::run_as_user "sed -i '/# vpn_ip/c\vpn_ip' ~/.p10k.zsh"
}

remove_exit(){
  # unset vpn icon for p10k.zsh
  cmd::run_as_user "sed -i '/vpn_ip/c\# vpn_ip' ~/.p10k.zsh"
}