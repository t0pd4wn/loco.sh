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
    prompt_option=$(echo $file_basename | cut -f 1 -d '.')
    prompt_option_name="$(tr '[:lower:]' '[:upper:]' <<< ${prompt_option:0:1})${prompt_option:1}"
    prompt_options+="${prompt_option_name} "
    argCases+="$prompt_index) printf -v ""${local_GLOBAL}"" '%s' "${prompt_option}";;\n"
  done
  # build prompt file
  echo "title=\"$(msg::say "${local_prompt_message}")\"" > "${prompt_path}"
  echo "prompt=\"$(msg::print "Pick an option : ")\"" >> "${prompt_path}"
  echo "options=("$prompt_options")" >> "${prompt_path}"
  echo "echo \$title" >> "${prompt_path}"
  echo "PS3=\$prompt" >> "${prompt_path}"
  echo "select opt in "'"${options[@]}"'" "Quit"; do " >> "${prompt_path}"
  echo "case "\$REPLY" in" >> "${prompt_path}"
  echo -e "$argCases" >> "${prompt_path}"
  echo "$((prompt_index+1))) echo "Goodbye!"; exit;;" >> "${prompt_path}"
  echo "*) echo "Invalid option. Try another one.";continue;;" >> "${prompt_path}"
  echo "esac" >> "${prompt_path}"
  echo "break" >> "${prompt_path}"
  echo "done" >> "${prompt_path}"
}

#######################################
# Call a prompt file
# Arguments:
#   $1 # path_suffix
#######################################
prompt::call(){
  local path_suffix="${1-}"
  # source built file
  utils::source ./src/temp/prompt_"${path_suffix}".sh
}