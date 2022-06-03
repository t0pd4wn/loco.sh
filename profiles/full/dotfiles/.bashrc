# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# count number of times .bashrc is sourced
startup_count(){
  if [[ -z "${BASH_START_STATUS-}" ]]; then
    # if not, set a global flag
    export BASH_START_STATUS=1
  elif [[ "${BASH_START_STATUS}" == 1 ]]; then
    BASH_START_STATUS=2
    readonly BASH_START_STATUS
  fi
}

# execute commands if .bashrc is sourced for the second time
system_startup(){
  echo -e "Installed with loco.sh \U1f335 You can edit this text in ~/.bashrc."
  # add some startup commands below
}

if [[ "${BASH_START_STATUS-}" -ne 2 ]]; then
  startup_count
fi

if [[ "${BASH_START_STATUS}" == 2 ]]; then
  system_startup
fi

# set zsh as default shell
zsh