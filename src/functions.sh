#!/bin/bash
#-------------------------------------------------------------------------------
# functions.sh | functions
#-------------------------------------------------------------------------------

# source the bash modules
# source the utils module
if ! source ./src/modules/utils.sh; then
  echo "Can not source ./src/modules/utils.sh" >&2
  exit 1
fi

# source other modules
utils::source ./src/modules/cli.sh
utils::source ./src/modules/cmd.sh
utils::source ./src/modules/loco.sh
utils::source ./src/modules/msg.sh
utils::source ./src/modules/prompt.sh

#######################################
# main
# GLOBALS:
#   ACTION
# Arguments:
#   $@ // script options
#######################################
main(){
  # launch startup checks and utils
  loco::startup "${@-}"

  # source action script
  utils::source ./src/actions/"${ACTION}".sh

  # display recorded commands script
  cmd::msg

  # display end message
  msg::end

  # trap custom last function
  if ! trap 'loco::custom_last' 0; then
    _error "Can not trap loco::custom_last"
  fi

  # end script
  exit $?
}