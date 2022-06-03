#!/bin/bash
#-------------------------------------------------------------------------------
# functions.sh | functions
#-------------------------------------------------------------------------------

# source the core modules
# source the utils module
if ! source ./src/modules/core/utils.sh; then
  echo "Can not source ./src/modules/utils.sh" >&2
  exit 1
fi

# source other core modules
utils::source ./src/modules/core/cli.sh
utils::source ./src/modules/core/cmd.sh
utils::source ./src/modules/core/msg.sh
utils::source ./src/modules/core/prompt.sh

# source loco modules
utils::source ./src/modules/loco/loco_background.sh
utils::source ./src/modules/loco/loco_custom_functions.sh 
utils::source ./src/modules/loco/loco_dotfiles.sh
utils::source ./src/modules/loco/loco_fonts.sh
utils::source ./src/modules/loco/loco_meta.sh
utils::source ./src/modules/loco/loco_prompts.sh
utils::source ./src/modules/loco/loco_startup.sh
utils::source ./src/modules/loco/loco_terminal.sh 
utils::source ./src/modules/loco/loco_watermark.sh
utils::source ./src/modules/loco/loco_yaml.sh

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

  # source main action script
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