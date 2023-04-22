#!/bin/bash
#-------------------------------------------------------------------------------
# pompt.sh | prompt.sh functions
#-------------------------------------------------------------------------------

#######################################
# Build a prompt shell file
# Arguments:
#   $1 # $ACTION (for readability)
#   $2 # prompt files path
#   $3 # prompt message
# Output:
#   ./src/prompts/prompt_$1.sh
#######################################
prompt::build(){
  local local_GLOBAL="${1-}"
  local local_dir="${2-}"
  local local_prompt_message="${3-}"
  local is_required="${4-}"
  local file_basename
  local prompt_index
  local prompt_option
  local prompt_option_name
  local prompt_options
  local prompt_path=./src/temp/prompt_"${local_GLOBAL}".sh
  declare -a argCases
  prompt_index=0
  for FILE in "${local_dir}"/*; do
    prompt_index=$((prompt_index+1))
    file_basename=$(basename "${FILE}")
    # prompt option only take the filename without extension
    # extension is later found back through find or static suffix
    prompt_option="${file_basename%.*}"
    prompt_option_name="$(tr '[:lower:]' '[:upper:]' <<< ${prompt_option:0:1})${prompt_option:1}"
    prompt_options+="'""${prompt_option_name}""' "
    argCases+="$prompt_index) printf -v ""${local_GLOBAL}"" '%s' '"${prompt_option}"';;\n"
  done
  # build prompt file
  _echo "title=\"$(msg::say "${local_prompt_message}")\"" > "${prompt_path}"
  _echo "prompt=\"$(msg::print "Pick an option : ")\"" >> "${prompt_path}"
  _echo "options=("$prompt_options")" >> "${prompt_path}"
  _echo "echo \$title" >> "${prompt_path}"
  _echo "PS3=\$prompt" >> "${prompt_path}"
  _echo "select opt in "'"${options[@]}"'" "Quit"; do " >> "${prompt_path}"
  _echo "case "\$REPLY" in" >> "${prompt_path}"
  _echo "$argCases" >> "${prompt_path}"

  if [[ "${is_required}" == true ]]; then
    _echo "$((prompt_index+1))) echo "Goodbye!"; exit;;" >> "${prompt_path}"
  elif [[ "${is_required}" == false ]]; then
    _echo "$((prompt_index+1))) echo "No choice is also good."; ;;" >> "${prompt_path}"
  fi
  
  _echo "*) echo "Invalid option. Try another one.";continue;;" >> "${prompt_path}"
  _echo "esac" >> "${prompt_path}"
  _echo "break" >> "${prompt_path}"
  _echo "done" >> "${prompt_path}"
}

#######################################
# Call a prompt file
# Arguments:
#   $1 # path_suffix
#######################################
prompt::call(){
  local path_suffix="${1-}"
  # source built file
  _source ./src/temp/prompt_"${path_suffix}".sh
}