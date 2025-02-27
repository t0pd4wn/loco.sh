#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | profile custom functions (execute as root)
#-------------------------------------------------------------------------------

#################
# all OS
#################
install_exit(){
  # add some specific startup lines in .loco_startup
  local file_path="${INSTANCE_PATH}/dotfiles/.loco_startup"
  local function="session_start"
  local instruction="# add vpn commands below 'openvpn_connect' or 'wireguard_connect'"
  loco::custom_add_to "${file_path}" "${function}" "${instruction}"
  loco::custom_add_to "${file_path}" "shell_start" "${instruction}"
  
  # set vpn icon for p10k.zsh
  cmd::run_as_user "perl -pi -e 's/# vpn_ip/vpn_ip/g' ~/.p10k.zsh"
}

remove_exit(){
  # unset vpn icon for p10k.zsh
  cmd::run_as_user "perl -pi -e 's/vpn_ip/# vpn_ip/g' ~/.p10k.zsh"
}