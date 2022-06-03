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
#   ~/loco-dist
#######################################
retrieve_public_archive(){
  local branch_name="gh-main"
  local release_url="https://github.com/t0pd4wn/loco.sh/raw/"${branch_name}"/dist/loco-dist.zip"
  # download archive
  if ! wget -nc -P ~/ "${release_url}"; then
    curl --create-dirs -LO --output-dir ~/ "${release_url}"
  fi
  loco::extract_and_run "$@"
}

#######################################
# Retrieve loco archive from a private server
# Arguments
#   ./loco "$@" ones
# Output:
#   ~/loco-dist
#######################################
retrieve_private_archive(){
  # modify below with your infos #
  local branch_name="gh-main"
  local git_server="https://gitlab.com"
  local project_ID="1234"
  local secret_key="ABC-123"
  # # # # end of modifications
  local private_header="PRIVATE-TOKEN: ${secret_key}"
  local release_url="${git_server}/api/v4/projects/${project_ID}/repository/files/dist%2Floco-dist.zip/raw?ref=${branch_name}"
  # download archive
  if ! wget --header="${private_header}" -nc -P ~/ "${release_url}"; then
    curl --header="${private_header}" --create-dirs -LO --output-dir ~/ "${release_url}"
  fi
  loco::extract_and_run "$@"
}

#######################################
# Extract loco archive and run main script
# Arguments
#   ./loco "$@" ones
#######################################
loco::extract_and_run(){
  # unzip archive
  unzip -oqq ~/loco-dist.zip -d ~/loco-dist
  # remove archive
  rm ~/loco-dist.zip
  # navigate to folder
  cd ~/loco-dist
  # set GLOBAL
  # launch loco
  ./loco "$@" -J
}

retrieve_public_archive "$@"