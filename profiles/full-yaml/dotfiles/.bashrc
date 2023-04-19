# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# WARNING : refrain to use .bashrc over macosx
# as the bash behavior may not be POSIX compliant there
# prefer .zprofile file or typical .zshrc
# source the startup scripts file
. ~/.loco_startup

# launch count
shell_status

# set a shared history file between shells
HISTFILE=~/.shell_history

# set zsh as default shell
zsh