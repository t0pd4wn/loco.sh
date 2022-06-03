#!/bin/bash
#-------------------------------------------------------------------------------
# clean_profiles.sh | clean the loco profiles before release
#-------------------------------------------------------------------------------

set -eu

#######################################
# Remove files from profiles folders
#######################################
clean_profiles(){
	sudo rm -r profiles/*/dotfiles/.vim/bundle/*
}

clean_profiles

set +eu