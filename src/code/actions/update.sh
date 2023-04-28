#!bin/bash
#-------------------------------------------------------------------------------
# uupdate.sh | update procedure (install.sh look-alike)
#-------------------------------------------------------------------------------

# prompt profiles, if none is set
loco::prompt_profile

# check watermark information
msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

# read and source "${PROFILE}" yaml file
msg::say "Reading " "${PROFILE}" " YAML"

# prompt themes, if none is set
loco::prompt_theme

# check for available backgrounds, prompt eventually
loco::background_manager

msg::say "Updating " "${PROFILE}" " profile"

# install custom "${PROFILE}" entry function
msg::say "Updating " "${LOCO_OSTYPE}" " entry function"
loco::custom_entry

# print entry scripts msg::says
msg::play

# install "${LOCO_OSTYPE}" packages
msg::say "Updating " "${LOCO_OSTYPE}" " packages"
loco::package_managers "${LOCO_OSTYPE}"

# install generic packages
msg::say "Updating " "generic" " packages"
loco::package_managers "generic"

# link "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Update your dotfiles with " "${PROFILE}" " ones (y/n)?"

# install fonts to system
msg::say "Updating " "fonts"
loco::fonts_manager

# build terminal conf
msg::say "Preparing " "terminal" " configuration"
loco::term_conf_manager

# install custom exit scripts
msg::say "Updating " "${LOCO_OSTYPE}" " exit scripts"
loco::custom_exit

# if no new fonts, exit normally
if [[ "${IS_NEW_FONT-}" != "true" ]]; then
	# record a closing terminal command in src/temp/finish.sh
	cmd::record "exit 2&>/dev/null"
else
	return 0
fi