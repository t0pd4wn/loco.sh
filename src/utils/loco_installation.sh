#!/bin/bash
#-------------------------------------------------------------------------------
# loco_installation.sh | install loco locally
#-------------------------------------------------------------------------------

set -eu

#######################################
# Retrieve loco archive from Github
# Arguments
#   ./loco "$@" ones
# Output:
#   ~/loco.sh-"${branch_name}"
#######################################
function retrieve_archive(){
  local branch_name="gh-main"
  # download archive
  wget -nc -P ~/ https://github.com/t0pd4wn/loco.sh/raw/"${branch_name}"/dist/loco-dist.zip
  # unzip archive
  unzip -oqq ~/loco-dist.zip -d ~/loco-dist
  # remove archive
  rm ~/loco-dist.zip
  # navigate to folder
  cd ~/loco-dist
  # launch loco
  exec ./loco "$@"
}

retrieve_archive "$@"