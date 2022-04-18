#!bin/bash
#-------------------------------------------------------------------------------
# remove.sh | remove procedure
#-------------------------------------------------------------------------------

msg::say "Checking " "${CURRENT_USER}" " watermark"
loco::watermark_check

# read and source "${PROFILE}" yaml file
loco::yaml_read

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
loco::watermark_set

# prepare term reset script
loco::term_conf_set