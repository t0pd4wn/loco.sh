#!bin/bash
#-------------------------------------------------------------------------------
# install.sh | install procedure
#-------------------------------------------------------------------------------

# prompt profiles, if none is set
loco::prompt_profile

# read and source "${PROFILE}" yaml file
msg::say "Reading " "${PROFILE}" " yaml_profile"
loco::yaml_profile

# prompt themes, if none is set
loco::prompt_theme

# check for available backgrounds, prompt eventually
loco::background_manager

# check watermark information
msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

msg::say "Installing " "${PROFILE}" " profile"

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

# link "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Replace your dotfiles with " "${PROFILE}" " ones (y/n)?"

# install fonts to system
msg::say "Installing " "fonts"
loco::fonts_manager

# build terminal conf
loco::term_conf_manager

# install custom exit scripts
msg::say "Installing " "${LOCO_OSTYPE}" " exit scripts"
loco::custom_exit

# install watermark
msg::say "Installing " "watermark"
loco::watermark_set

# record a closing terminal command in loco_finish.sh
cmd::record 'kill -9 $PPID'