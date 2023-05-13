#!/bin/bash
#-------------------------------------------------------------------------------
# utils.sh | utils functions
#-------------------------------------------------------------------------------

#######################################
# Removes temp files.
#######################################
utils::clean_temp(){
  utils::remove './src/temp/*'
}

#######################################
# Display a countdown
# Arguments:
#   $1 # message to be displayed
#   $2 # countdown duration
#######################################
utils::countdown(){
  local message="${1-}"
  local duration="${2-}"
  # local seconds=$((1 * "${duration}"))
  local seconds="${duration}"
  while [ $seconds -gt 0 ]; do
    if [[ "${message}" != "" ]]; then
     echo -ne "${message}" "$seconds\033[0K\r"
    fi
     sleep 1
     : $((seconds--))
  done
}

#######################################
# Compare two files
# Arguments:
#   $1 # /path/to/a/file
#   $2 # /path/to/a/second/file
# Output:
#    a boolean
#######################################
utils::compare(){
  local file_A="${1-}"
  local file_B="${2-}"
  local file_A_size=$(_file_size "${file_A}")
  local file_B_size=$(_file_size "${file_B}")

  if [[ "${file_A_size}" -eq "${file_B_size}"  ]]; then
    if ! $(cmp -s ${file_A} ${file_B}); then
    _error "Unable to cmp ${file_A} with ${file_B}"
    fi

    if (( $? != 0 )); then
      # if not 0
      echo false
    else
      # if 0, files are the same
      echo true
    fi

  else
    # files sizes are different
    echo false
  fi
}

#######################################
# Dump a bash function
# Arguments:
#   $1 # a function name"
#   $2 # /path/to/a/script.sh
#######################################
utils::dump_bash_function(){
  local name="${1-}"
  local path="${2-}"

  source "${path}"

  if [[ $(type -t "${name}") == function ]]; then
    if ! type "${name}" | sed '1,3d;$d'; then
      _error "Unable to dump ${name} from ${path}"
    fi
  fi
}

#######################################
# Dump a bash function name
# Arguments:
#   $1 # a function name"
#   $2 # /path/to/a/script.sh
#######################################
utils::find_filename(){
  local name="${1-}"
  local path="${2-}"

  source "${path}"

  if [[ $(type -t "${name}") == function ]]; then
    if ! type "${name}" | sed '1,3d;$d'; then
      _error "Unable to dump ${name} from ${path}"
    fi
  fi
}

#######################################
# Get the function names in bash script
# Arguments:
#   $1 # /path/to/a/file
#######################################
utils::list_bash_functions(){
  local file="${1-}"
  local grep_arg='^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)+)'

  if ! grep -E  "${grep_arg}" "${file}" | cut -d"(" -f 1; then
    _error "Unable to get functions names from ${file}"
  fi
}

#######################################
# Get the last part of a string
# Arguments:
#   $1 # a string
#   $2 # a delimeter
#######################################
utils::get_string_last(){
  local string="${1-}"
  local delimeter="${2-}"

  if ! echo "${url}" | rev  | cut -d "${delimeter}" -f1 | rev; then
    _error "Can not get ${string} last part"
  fi
}

#######################################
# Escape special characters in a path
# Arguments:
#   $1 # a path with special characters
#######################################
utils::escape_string(){
  local string="${@-}"
  if ! printf %q "${string}"; then
    _error "Unable to escape ${string}"
  fi
}

#######################################
# Encode a path to URI
# Arguments:
#   $1 # a path
#######################################
utils::encode_URI(){
  local string="${@-}"
  if ! echo "${string}"| perl -MURI::file -e 'print URI::file->new(<STDIN>)'; then
    _error "Unable to decode ${string}"
  fi
}

#######################################
# Decode an URI to a path
# Arguments:
#   $1 # an URI
#######################################
utils::decode_URI(){
  local string="${@-}"
  if ! echo ''"${string}"'' | perl -pe 's/\%(\w\w)/chr hex $1/ge'; then
    _error "Unable to decode ${string}"
  fi
}

#######################################
# Get a file from an URL into a folder.
# Arguments:
#   $1 # a folder path
#   $2 # an url
#######################################
utils::get_url(){
  local path="${1-}"
  local url="${2-}"
  local wget_options="-nc -q -P"
  local curl_options="--create-dirs -C - -LOs --output-dir"
  if eval 'command -v wget' > /dev/null 2>&1; then
    msg::debug "wget is used"
    cmd::run_as_user "wget ${wget_options} " "${path}" "'"${url}"'"
  else
    msg::debug "curl is used"
    cmd::run_as_user "curl ${curl_options} " "${path}" "'"${url}"'"
  fi
}

#######################################
# Return domain from an url
# Arguments:
#   $1 # an url
#######################################
utils::get_url_domain(){
  local url="${1-}"

  if ! _echo "${url}" | awk -F/ '{print $3}'; then
    _error "Unable to retrieve domain from ${url}"
  fi
}

#######################################
# Add a transparent image over another
# Arguments:
#   $1 # a normal image path
#   $2 # a transparent png path
#   $3 # is an optional output pathname
#######################################
utils::image_overlay(){
  local img_path="${1-}"
  local ovl_path="${2-}"
  local out_path="${3:-"img+overlay-output.jpg"}"
  local ratio_flag=false
  local img_sz
  local img_wd
  local img_ht
  local img_ratio

  # get the background width and height
  img_wd=$(identify -format '%w' "${img_path}")
  img_ht=$(identify -format '%h' "${img_path}")

  # calculate the background ratio
  img_ratio=$(bc <<< "scale=2; "${img_wd}"/"${img_ht}"")

  # if background ratio under 1.77 resize it
  if (( $(bc -l <<< "${img_ratio} < 1.77") )); then
    ratio_flag=true
    msg::print "Original background doesn't fit."
    msg::print "It will be backup'd and resized."
    # backup orginal background
    _cp "${img_path}" "${img_path}.temp"
    # modify original background resolution
    cmd::run_as_user "convert "${img_path}" -resize 3840x2160^ -gravity Center -extent 3840x2160 "${img_path}""
  fi 

  msg::debug "${ratio_flag}"

  # get the background width and height
  img_sz=$(identify -format '%wx%h' "${img_path}")

  # send background and overlay to imagemagick composite
  msg::print "Applying overlay to background image."
  cmd::run_as_user "convert -size "${img_sz}" -composite "${img_path}" "${ovl_path}" -geometry "${img_sz}""+0+0" -depth 8 "${out_path}""

  # restore original background and clean temp files
  if [[ "${ratio_flag}" == true ]]; then
    utils::remove "${img_path}"
    _cp "${img_path}.temp" "${img_path}"
    utils::remove "${img_path}.temp"
  fi
}

#######################################
# List files and folders within an array
# Arguments:
#   $1 # a normative array name
#   $2 # a path
#   $3 # an option [clear, hidden, all (default)]
# 
#######################################
utils::list(){
  local -n list_name="${1-}"
  local list_path="${2-}"
  local option="${3-"all"}"

  local paths
  local element_name

  # meant to clean a previously existing array
  list_name=()

  # check $option and set paths
  if [[ "${option}" == "all" ]]; then
    paths="${list_path}/.??* ${list_path}/*"
  elif [[ "${option}" == "clear" ]]; then
    paths="${list_path}/*"
  elif [[ "${option}" == "hidden" ]]; then
    paths="${list_path}/.??*"
  fi

  # prevail empty folders
  shopt -s nullglob

  # iterate over aguments paths
  for element_path in ${paths}; do
    # substitute a / ?
    element_name=${element_path##*/}
    list_name+=("${element_name}")
  done

  shopt -u nullglob
}

#######################################
# Remove a path
# Arguments:
#   $1 # a path
#######################################
utils::remove(){
  local path="${@-}"
  declare -a clean_path
  # this is meant to enable variables expansion in remove paths
  clean_path=($(eval echo ${path[@]}))

  # try three different expansions 
  if ! rm -Rr "${clean_path[@]}"; then
    if ! rm -Rr $clean_path; then
      if ! rm -Rr "$clean_path"; then
        msg::debug "Unable to remove $clean_path"
        _error "Unable to remove $clean_path"
      else 
        msg::debug "Managed to remove "$clean_path" (3)"
      fi
    else
      msg::debug "Managed to remove $clean_path (2)"
    fi
  else 
    msg::debug "Managed to remove "${clean_path[@]}" (1)"
  fi
}

#######################################
# Remove a file
# Arguments:
#   $1 # a file path
#######################################
utils::remove_file(){
  local path="${@-}"

  # try three different expansions 
  if ! rm -R "${path}"; then
    if ! rm -R $path; then
      if ! rm -R "$path"; then
        msg::debug "Unable to remove $path"
        _error "Unable to remove $path"
      else 
        msg::debug "Managed to remove "$path" (3)"
      fi
    else
      msg::debug "Managed to remove $path (2)"
    fi
  else 
    msg::debug "Managed to remove "${path}" (1)"
  fi
}

#######################################
# Remove a string from a file
# Arguments:
#   $1 # a string
#   $2 # a file path
#######################################
utils::remove_string_in_file(){
  local string="${1-}"
  local file="${2-}"

  if ! sed -i 's/'"${string}"'//' "${file}"; then
    _error "Unable to remove ${string} in ${file}"
  fi
}

#######################################
# Replace a text block within a file
# Notes :
#   as the text block is a regex pattern within perl
#   special characters such as single and double quotes 
#   in "$3 # template content", must be escaped under their hex codes
#   e.g. \x27 for single quote and \x22 for double quotes
# Arguments:
#   $1 # template first part (beginning of searched string)
#   $2 # template last part (end of searched string)
#   $3 # template content
#   $4 # file to be modified path 
#######################################
utils::replace_block_in_file(){
  local template_first_part="${1-}"
  local template_last_part="${2-}"
  local new_content="${3-}"
  local file_path="${4-}"

  local search_pattern="${template_first_part}".*?"${template_last_part}"
  local search_and_replace='s/'"${search_pattern}"'/"'"${new_content}"'"/se'

  if ! perl -i -p0e "${search_and_replace}" "${file_path}"; then
    _error "Unable to replace text in "${file_path}""
  fi
}

#######################################
# Cut a string
# Arguments:
#   $1 # a string ex: "Hello/world"
#   $2 # delimeter ex: "/"
#   $3 # part to be retrieved ex: "1"
#######################################
utils::string_cut(){
  local string="${1-}"
  local delimeter="${2-}"
  local part="${3-}"
  local command="echo "${string}" | cut -d "${delimeter}" -f "${part}""

  if ! cmd::run_as_user ${command}; then
    _error "Unable to cut ${string}"
  fi
}

#######################################
# Cut a string (reverse)
# Arguments:
#   $1 # a string ex: "Hello/world"
#   $2 # delimeter ex: "/"
#   $3 # part to be retrieved ex: "3"
#######################################
utils::string_cut_rev(){
  local string="${1-}"
  local delimeter="${2-}"
  local part="${3-}"
  local command="echo "${string}" | rev | cut -d "${delimeter}" -f "${part}" | rev"

  if ! cmd::run_as_user ${command}; then
    _error "Unable to reverse cut ${string}"
  fi
}

#######################################
# Replace a string within a file
# Arguments:
#   $1 # searched string
#   $2 # replace string
#   $4 # file to be modified path 
#######################################
utils::replace_string_in_file(){
  local search="${1-}"
  local replace="${2-}"
  local path="${3-}"

  if ! sed -i -e 's/'"${search}"'/'"${replace}"'/g' "${path}"; then
    _error "Unable to replace text in "${file_path}""
  fi
}

#######################################
# Set system clock (needed in  virtual hosts)
#######################################
utils::set_clock(){
  if ! sudo hwclock --hctosys; then
    _error "Unable to set clock"
  fi
}

#######################################
# Print a timestamp.
#######################################
utils::timestamp(){
  # print current time
  date +"%Y-%m-%d_%H-%M-%S"
}

#############################
# Wget a file in a folder. (deprecated in favor to utils::get_url)
# Arguments:
#   $1 # a path
#   $2 # an url
#######################################
# utils::wget(){
#   local path="${1-}"
#   local url="${2-}"
#   if ! cmd::run_as_user "wget -nc -q -P " "${path}" "${url}"; then
#     msg::debug "Unable to wget ${url}"
#     _error "Unable to wget ${url}"
#   fi
# }