# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# execute commands if .bashrc is sourced for the first time
system_ENV(){
  # add some environment variables below
  export LOCO_SESSION=true
}

# execute commands if .bashrc is sourced for the second time
system_startup(){
  echo -e "Installed with loco.sh \U1f335 You can edit this text in ~/.bashrc."
  # add some startup commands below
}

# count number of times .bashrc is sourced
startup_status(){
  if [[ -z "${BASH_START_STATUS}" ]]; then
    # if not, set a global flag at startup
    export BASH_START_STATUS=true
    # remove lock file
    rm -rf ~/.is_started
    # add environment variables once
    system_ENV
  elif [[ ! -z "${BASH_START_STATUS}" ]]; then
    # if the global flag is set, creates a lock file
    if [[ ! -f ~/.is_started ]]; then
      touch ~/.is_started
      # launch startup function once
      system_startup
    fi
  fi
}

# launch count
startup_status

# set zsh as default shell
zsh