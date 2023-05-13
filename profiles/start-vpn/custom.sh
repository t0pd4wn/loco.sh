#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  cmd::run_as_user "sed -i '/# vpn_ip/c\vpn_ip' ~/.p10k.zsh"
}

remove_exit(){
  cmd::run_as_user "sed -i '/vpn_ip/c\# vpn_ip' ~/.p10k.zsh"
}