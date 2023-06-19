#!bin/bash
#-------------------------------------------------------------------------------
# install_sys.sh | system install procedure
#-------------------------------------------------------------------------------

# prompt profiles, if none is set
loco::prompt_profile

# check for existing watermark or create one
msg::say "Checking for a previous " "${CURRENT_USER}" " watermark"
loco::watermark_check

# read and source "${PROFILE}" yaml file
msg::say "Sourcing " "${PROFILE}" " YAML"

msg::say "Installing " "${PROFILE}" " profile"

# install custom "${PROFILE}" entry function
msg::say "Installing " "${LOCO_OSTYPE}" " entry function"
loco::custom_entry

# print entry scripts msg::says
msg::play

# install "${LOCO_OSTYPE}" packages
msg::say "Installing " "${LOCO_OSTYPE}" " packages"
loco::package_managers "${LOCO_OSTYPE}"

# install generic packages
msg::say "Installing " "generic" " packages"
loco::package_managers "generic"

# link "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Replace your dotfiles with " "${PROFILE}" " ones (y/n)?"

# install custom exit scripts
msg::say "Running " "${LOCO_OSTYPE}" " exit scripts"
loco::custom_exit

# if no new fonts, exit normally
if [[ "${IS_NEW_FONT-}" != "true" ]]; then
	# record a closing terminal command in loco_finish.sh
	cmd::record "exit 2&>/dev/null"
else
	return 0
fi