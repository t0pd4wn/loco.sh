#!/bin/bash
#-------------------------------------------------------------------------------
# loco_merge_profiles.sh | loco.sh merge profiles functions
#-------------------------------------------------------------------------------

########################################
# Check if one or more profiles are set
# GLOBALS:
#   PROFILES_DIR
#   PROFILE
# Arguments:
#   $1 # "${PROFILE}"
########################################
loco::profile_prepare(){
  # if a $PROFILE option is set
  # split the option on the "," character 
  declare -a profile_option
  declare -a profile_imports
  local profile_length
  local profile_dir
  local is_profile
  local yaml_temp="src/temp/profiles.yaml"
  declare -gA LOCO_PROFILES_SEQUENCE

  # clean $PROFILE from commas (in case of multiple profiles option)
  PROFILE="${PROFILE/,/ }"
  profile_option=(${PROFILE})

  # initiate a temp yaml file with a "profiles" selector
  _echo "profiles:" > "${yaml_temp}"

  # loop over multiple profiles option
  for profile in "${profile_option[@]}"; do
    profile_dir="./${PROFILES_DIR}/${profile}"
    if [[ -d "${profile_dir}" ]]; then
      yaml::add "${yaml_temp}" ".profiles.to_import" "${profile}"
    else
      msg::print "${EMOJI_STOP} " "${profile} " "doesn't exist."
      is_profile=false
    fi
  done

  if [[ "${is_profile-}" == false ]]; then
    _exit "Profile doesn't exist."
  fi

  # send profile(s) to import to the recursive import function
  msg::say "Checking dependencies for " "${profile_option[@]}" "."
  msg::say "This can be long if you have nested dependencies."
  loco::profile_manage_imports "${yaml_temp}"

  # list profiles after depackaging 
  profile_imports=($(yaml::get "${yaml_temp}" ".profiles.import[]"))
  profile_length=${#profile_imports[@]}

  if [[ "${profile_length}" -gt 1 ]]; then
  # if there is more than one profile, merge profiles
    loco::multi_prepare "${profile_imports[@]}"
  else
  # if there is only one profile, proceed
    PROFILE="${profile_option[@]}"
  fi

  # store profile names
  LOCO_IMPORT_PROFILES=("${profile_imports[@]}")
}

########################################
# Check if there are profiles in ".profiles.to_import"
# Arguments:
#   $1 #  /path/to/temp/yaml 
########################################
loco::profile_manage_imports(){
  local yaml_temp="${1-}"
  declare -a profiles_to_import
  declare -a parent_profiles

  profiles_to_import=($(yaml::get "${yaml_temp}" ".profiles.to_import[]"))

  # if there are import profiles to be managed
  if [[ -n "${profiles_to_import[@]}" ]]; then
    loco::profile_manage_imports_dependencies "${yaml_temp}"
  else
    parent_profiles=($(yaml::get "${yaml_temp}" ".profiles.parent[]"))
    # if there are parent profiles, copy them in the import list
    if [[ -n "${parent_profiles[@]}" ]]; then
      for parent in "${parent_profiles[@]}"; do
        yaml::add "${yaml_temp}" ".profiles.import" "${parent}"
      done
    fi
  fi
}

########################################
# Import profiles from each profiles ".profiles.import"
# Arguments:
#   $1 #  /path/to/temp/yaml 
########################################
loco::profile_manage_imports_dependencies(){
  local yaml_temp="${1-}"
  declare -a profiles_to_import
  declare -a profiles_imports
  declare -a profiles_sequence
  declare -a child_profiles
  local profile_yaml
  local has_profile
  local is_parent

  profiles_to_import=($(yaml::get "${yaml_temp}" ".profiles.to_import[]"))

  profiles_length="${#profiles_to_import[@]}"

  for profile in "${profiles_to_import[@]}"; do
    msg::debug "Checking dependencies for " "${profile}" " profile."
    profile_yaml="./"${PROFILES_DIR}"/"${profile}"/profile.yaml"
    
    # swap the profile from one list to the other
    # yaml::add "${yaml_temp}" ".profiles.import" "${profile}"
    yaml::delete "${yaml_temp}" ".profiles.to_import" "${profile}"  

    if [[ -f "${profile_yaml}" ]]; then
      # get profile imports from profile yaml
      profile_imports=($(yaml::get "${profile_yaml}" ".profiles.import[]"))
    else
      # if there is no yaml file in the profile, exit loop
      msg::debug "" "${profile}" " has no yaml file."
      # add the profile to future imports
      yaml::add "${yaml_temp}" ".profiles.import" "${profile}"
      break
    fi

    if [[ -z "${profile_imports[@]}" ]]; then
      # if there are no imports
      msg::debug "" "${profile}" " has no dependencies."
      # add the profile to future imports
      yaml::add "${yaml_temp}" ".profiles.import" "${profile}"
    else
      # if there is imports
      msg::debug "Importing " "${profile}" " dependencies."
      # if there are child profiles, add the profile to the parent list
      yaml::add "${yaml_temp}" ".profiles.parent" "${profile}"
      for import in "${profile_imports[@]}"; do
        # echo "${import}"
        has_profile=$(yaml::contains "${yaml_temp}" ".profiles.import" "${import}")
        # echo "${has_profile}"
        is_parent=$(yaml::contains "${yaml_temp}" ".profiles.parent" "${import}")

        if [[ "${has_profile}" == false && "${is_parent}" == false ]]; then
          # this will add the import profile only if it isn't in the list already
          # add the child profile to the child list
          yaml::add "${yaml_temp}" ".profiles.child" "${import}"
        elif [[ "${is_parent}" == true ]]; then
          if [[ "${import}" == "${profile}" ]]; then
            # if the child and parent profiles are the same
            msg::print "${EMOJI_STOP} " "${profile}" " tries to import itself."
          else
            parent_yaml="./"${PROFILES_DIR}"/"${import}"/profile.yaml"
            if [[ -f "${parent_yaml}" ]]; then
              has_profile=$(yaml::contains "${parent_yaml}" ".profiles.import" "${profile}")
              if [[ "${has_profile}" == true ]]; then
                # if both parent profiles are imported from each others
                msg::print "${EMOJI_STOP} " "${profile} and ${import}" " are each others dependencies. This will provoke a loose dependency tree."
              fi
            fi
          fi
          yaml::add_after "${yaml_temp}" ".profiles.parent" "${import}" "${profile}"
        fi
      done
    fi
  done

  # reset to_import list with the child list content
  child_profiles=($(yaml::get "${yaml_temp}" ".profiles.child[]"))
  for child in "${child_profiles[@]}"; do
    yaml::add "${yaml_temp}" ".profiles.to_import" "${child}"
    yaml::delete "${yaml_temp}" ".profiles.child" "${child}"
  done

  # call back parent function
  loco::profile_manage_imports "${yaml_temp}"
}

########################################
# Prepare .Multi folder for receiving other profiles
# GLOBALS:
#   PROFILES_DIR
# Arguments:
#   $1 # an array of profiles
########################################
loco::multi_prepare(){
  declare -a profiles
  profiles=("${@}")
  local profiles_length="${#profiles[@]}"

  PROFILE=".Multi-$(utils::timestamp)"

  msg::say "Preparing the multi profiles assets folder."

  # create a .Multi folder
  _mkdir "./${PROFILES_DIR}/${PROFILE}"
  _mkdir "./${PROFILES_DIR}/${PROFILE}/assets"
  _mkdir "./${PROFILES_DIR}/${PROFILE}/dotfiles"

  for (( i = "${profiles_length}"-1; i >= 0; i-- )); do
    loco::multi_assets "${profiles[$i]}"
    loco::multi_dotfiles "${profiles[$i]}"
    loco::multi_yaml "${profiles[$i]}"
    loco::multi_custom_functions "${profiles[$i]}"
  done


    echo "AFTER"
}

########################################
# Copy profiles assets
# GLOBALS:
# Arguments:
#   $1 # a profile name
########################################
loco::multi_assets(){
  local profile_arg="${1-}"
  local from="./${PROFILES_DIR}/${profile_arg}/assets"
  local to="./${PROFILES_DIR}/${PROFILE}/assets"
  
  # if $profile/assets/ exists copy content in .Multi/assets/
  if [[ -d "${from}" ]]; then
    _cp "${from}/*" "${to}"
  fi
}

########################################
# Merge profiles dotfiles
# GLOBALS:
# Arguments:
#   $1 # "entry" or "exit"
########################################
 loco::multi_dotfiles(){
  local profile_arg="${1-}"
  local from_path=./${PROFILES_DIR}/"${profile_arg}"/dotfiles
  local dest_path=./${PROFILES_DIR}/${PROFILE}/dotfiles

  # if the child profile has a dotfiles folder
  if [[ -d "${from_path}" ]]; then
    if [[ $(ls -A ${dest_path}) ]]; then
    # if destination folder is not empty
      loco::dotfiles_merge "${from_path}" "${dest_path}"
    else
    # if empty, copy files in destination folder
      _cp "${from_path}/." "${dest_path}/"
    fi
  fi
 }

########################################
# Merge profiles yaml
# GLOBALS:
# Arguments:
#   $1 # from profile
########################################
 loco::multi_yaml(){
  local profile_arg="${1-}"
  local from_yaml=./${PROFILES_DIR}/"${profile_arg}"/profile.yaml
  local dest_yaml=./${PROFILES_DIR}/${PROFILE}/profile.yaml

  # if sub profile has a profile.yaml file to copy from 
  if [[ -f "${from_yaml}" ]]; then
    if [[ -f "${dest_yaml}" ]]; then
    # if destination file exists, merge files
      loco::yaml_merge "${from_yaml}" "${dest_yaml}"
    else
    # if not, copy file as destination file
      _cp "${from_yaml}" "${dest_yaml}"
    fi
  fi
 }

 ########################################
# Merge profiles custom functions files
# GLOBALS:
# Arguments:
#   $1 # from profile
########################################
loco::multi_custom_functions(){
  local profile_arg="${1-}"
  local from_custom=./${PROFILES_DIR}/"${profile_arg}"/custom.sh
  local dest_custom=./${PROFILES_DIR}/${PROFILE}/custom.sh

  # if sub profile has a custom.sh file to copy from 
  if [[ -f "${from_custom}" ]]; then
    if [[ -f "${dest_custom}" ]]; then
    # if destination file exists, merge files
      loco::custom_merge "${from_custom}" "${dest_custom}"
    else
    # if not, copy file as destination file
      _cp "${from_custom}" "${dest_custom}"
    fi
  fi
}