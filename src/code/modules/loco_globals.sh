#!/bin/bash
#-------------------------------------------------------------------------------
# globals.sh | globals variables management
#-------------------------------------------------------------------------------

#######################################
# Set GLOBALS
#######################################
loco::GLOBALS_set(){
  # used in profile management
  PROFILE_YAML=""
  # used in package management
  PACKAGE_MANAGER_TEST_CMD=""
  PACKAGE_TEST_CMD=""
  PACKAGE_ACTION_CMD=""
  # used in wget installation
  # LOCO_DIST=""
  # emojis

  readonly EMOJI_LOGO="\U1f335"
  readonly EMOJI_STOP="\U1F6A8"
  readonly EMOJI_YES="\U1F44D"
  readonly EMOJI_NO="\U1F44E"
}

#######################################
# Lock GLOBALS
#######################################
loco::GLOBALS_lock(){
  # can be reset or defined at runtime
  # readonly CURRENT_USER
  # readonly PROFILE_YAML
  # readonly INSTANCE_YAML
  # readonly PROFILE_PATH
  # readonly INSTANCE_PATH
  # readonly SHORT_OS_VERSION
  # readonly ACTION
  # readonly PROFILE
  # readonly THEME
  # readonly BACKGROUND_URL
  # readonly IS_NEW_FONT

  readonly PROFILES_DIR
  readonly INSTANCES_DIR
  readonly CONFIG_PATH
  readonly WATERMARK
  readonly DETACHED
  readonly LOCO_YES
  readonly VERBOSE
  readonly VERSION
  readonly OS_PREFIX
  readonly SHORT_OS_VERSION
  readonly LOCO_OS_TYPE
}