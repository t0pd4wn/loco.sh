#!bin/bash
#-------------------------------------------------------------------------------
# install.sh | install procedure
#-------------------------------------------------------------------------------

# build and source the profiles prompt file, if there is no -p option
if [ -z "${PROFILE}" ]; then
	prompt::build "PROFILE" "./profiles" "Choose a profile :"
	prompt::call "PROFILE"
fi

msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

msg::say "Installing " "${PROFILE}" " profile"

# read and source "${PROFILE}" yaml file
msg::say "Reading " "${PROFILE}" " YAML"
loco::yaml_read

# install custom "${PROFILE}" entry function
msg::say "Installing " "${LOCO_OSTYPE}" " entry function"
loco::custom_entry

# print entry scripts msg::says
msg::play

# install "${LOCO_OSTYPE}" packages
msg::say "Installing " "${LOCO_OSTYPE}" " packages"
loco::meta_package_manager "${LOCO_OSTYPE}"

# install generic packages
msg::say "Installing " "generic" " packages"
loco::meta_package_manager "generic"

# #link "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Replace your dotfiles with " "${PROFILE}" " ones (y/n)?"

#install fonts to system
msg::say "Installing " "fonts"
loco::fonts_manager

#build terminal conf
loco::term_conf_set

#install custom exit scripts
msg::say "Installing " "${LOCO_OSTYPE}" " exit scripts"
loco::custom_exit

#install watermark
msg::say "Installing " "watermark"
loco::watermark_set

#record a closing terminal command in loco_finish.sh
cmd::record 'kill -9 $PPID'