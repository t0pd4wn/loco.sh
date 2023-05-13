#!/bin/bash
#-------------------------------------------------------------------------------
# patch_p10k.sh | prepare p10k.zsh for terminal color palette
#-------------------------------------------------------------------------------

#######################################
# Prepare p10k.zsh for terminal color palette
# Attributes:
#   $1 # a path to p10k.zsh file
#######################################

patch_p10k(){
  local path="${1-}"

  sed -i '/POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND/c\typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=240' "${path}"
  sed -i '/POWERLEVEL9K_BACKGROUND/c\typeset -g POWERLEVEL9K_BACKGROUND=236' "${path}"
  sed -i "/POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR/c\typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%244F\\\u2502'" "${path}"
  sed -i "/POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR/c\typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%244F\\\u2502'" "${path}"
  sed -i '/POWERLEVEL9K_OS_ICON_FOREGROUND/c\typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7' "${path}"
  sed -i '/POWERLEVEL9K_PROMPT_CHAR_OK_/c\typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=2' "${path}"
  sed -i '/POWERLEVEL9K_PROMPT_CHAR_ERROR_/c\typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=1' "${path}"
  sed -i '/POWERLEVEL9K_DIR_FOREGROUND/c\typeset -g POWERLEVEL9K_DIR_FOREGROUND=7' "${path}"
  sed -i '/POWERLEVEL9K_DIR_ANCHOR_FOREGROUND/c\POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=7' "${path}"
  sed -i "/POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX/c\typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%0F╭─'" "${path}"
  sed -i "/POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX/c\typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%0F├─'" "${path}"
  sed -i "/POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX/c\typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%0F╰─'" "${path}"
  sed -i "/local       meta='%244F'  # grey foreground/c\local       meta='%244F'  # grey stale foreground" "${path}"
  sed -i "/local      clean='%244F'  # grey foreground/c\local      clean='%244F'  # grey stale foreground" "${path}"
  sed -i "/local   modified='%244F'  # grey foreground/c\local   modified='%244F'  # grey stale foreground" "${path}"
  sed -i "/local  untracked='%244F'  # grey foreground/c\local  untracked='%244F'  # grey stale foreground" "${path}"
  sed -i "/local conflicted='%244F'  # grey foreground/c\local conflicted='%244F'  # grey stale foreground" "${path}"
  sed -i "/# grey foreground/c\local       meta='%036F'  # grey foreground" "${path}"
  sed -i "/# yellow foreground/c\local      clean='%003F'  # yellow foreground" "${path}"
  sed -i "/# orange foreground/c\local   modified='%202F'  # orange foreground" "${path}"
  sed -i "/# blue foreground/c\local  untracked='%004F'  # blue foreground" "${path}"
  sed -i "/# red foreground/c\local conflicted='%001F'  # red foreground" "${path}"
  sed -i '/POWERLEVEL9K_STATUS_OK_FOREGROUND/c\POWERLEVEL9K_STATUS_OK_FOREGROUND=2' "${path}"
  sed -i '/POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND/c\POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=2' "${path}"
  sed -i '/POWERLEVEL9K_STATUS_ERROR_FOREGROUND/c\POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1' "${path}"
  sed -i '/POWERLEVEL9K_STATUS_SIGNAL_FOREGROUND/c\POWERLEVEL9K_STATUS_SIGNAL_FOREGROUND=1' "${path}"
  sed -i '/POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND/c\POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=1' "${path}"
  sed -i '/POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND/c\typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=2' "${path}"
  sed -i '/POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR/c\typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=3' "${path}"
}

patch_p10k "${@}"