# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# check if a BASH_IS_START flag is set
if [[ -z "${BASH_IS_START-}" ]]; then
	# if not, set a global flag
	export BASH_IS_START=true
	# insert custom startup commands below
fi

# set zsh as default shell
zsh