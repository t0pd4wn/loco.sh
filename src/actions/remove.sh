#!bin/bash
#-------------------------------------------------------------------------------
# remove.sh | remove procedure
#-------------------------------------------------------------------------------

# check watermark information
msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

# read and source "${PROFILE}" yaml file
loco::yaml_profile

# reset background to OS default
loco::background_manager

# unlink "${PROFILE}" .dotfiles to $USER
loco::dotfiles_manager "Replace your dotfiles with " "${CURRENT_USER}" " ones (y/n)?"

# install custom entry scripts
msg::say "Executing entry function"
loco::custom_entry

# entry function recorded message(s)
msg::play

# remove operating system packages
msg::say "Removing operating system packages"
loco::meta_package_manager "${LOCO_OSTYPE}"

# remove custom or linguage specific packages
msg::say "Removing custom or linguage specific packages"
loco::meta_package_manager "generic"

# todo : remove fonts from system
msg::say "Removing fonts"
loco::fonts_manager

# install exit scripts
msg::say "Executing exit function"
loco::custom_exit

# remove watermark
loco::watermark_unset

# prepare term reset script
loco::term_conf_manager

# record a reset terminal command in loco_finish.sh
cmd::record "reset && exit"