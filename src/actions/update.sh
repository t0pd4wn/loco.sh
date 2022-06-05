#!bin/bash
#-------------------------------------------------------------------------------
# uupdate.sh | update procedure (install.sh look-alike)
#-------------------------------------------------------------------------------

# prompt profiles, if none is set
loco::prompt_profile

# read and source "${PROFILE}" yaml file
msg::say "Reading " "${PROFILE}" " YAML"
loco::yaml_profile

# prompt themes, if none is set
loco::prompt_theme

# check for available backgrounds, prompt eventually
loco::background_manager

# check watermark information
msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

msg::say "Updating " "${PROFILE}" " profile"

# install custom "${PROFILE}" entry function
msg::say "Updating " "${LOCO_OSTYPE}" " entry function"
loco::custom_entry

# print entry scripts msg::says
msg::play

# install "${LOCO_OSTYPE}" packages
msg::say "Updating " "${LOCO_OSTYPE}" " packages"
loco::meta_package_manager "${LOCO_OSTYPE}"

# install generic packages
msg::say "Updating " "generic" " packages"
loco::meta_package_manager "generic"

# link "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Replace your dotfiles with " "${PROFILE}" " ones (y/n)?"

# install fonts to system
msg::say "Updating " "fonts"
loco::fonts_manager

# build terminal conf
msg::say "Preparing " "terminal" " configuration"
loco::term_conf_manager

# install custom exit scripts
msg::say "Updating " "${LOCO_OSTYPE}" " exit scripts"
loco::custom_exit

# install watermark
msg::say "Updating " "watermark"
loco::watermark_set

# record a closing terminal command in loco_finish.sh
# if no new fonts, exit normally
# funny spelling to create a silent error
if [[ "${IS_NEW_FONT-}" != "true" ]]; then
	cmd::record "exit 2&>/dev/null"
fi