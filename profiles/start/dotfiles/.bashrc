# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# source loco startup scripts file
. ~/.loco_startup

# check if in an interactive session
if [[ -n "$PS1" ]]; then
	# check start status
	is_started
fi