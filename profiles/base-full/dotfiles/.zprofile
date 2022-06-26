# if on macOS source startup script from here
# on ubuntu, source from .bashrc
if [[ "$OSTYPE" == "darwin"* ]]; then
  # source startup functions
  . ~/.loco_startup 

  # launch status count
  shell_status

  ### MacOS font setup
  # osascript command goes here
  # osascript -e 'tell application "Terminal" to set the font name of window 1 to "fontname"'
  # osascript -e 'tell application "Terminal" to set the font size of window 1 to "fontsize"'
  ###
fi