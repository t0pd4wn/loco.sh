# if on macOS source startup script from here
# on ubuntu, source from .bashrc

### MacOS font setup
# osascript command goes here
# osascript -e 'tell application "Terminal" to set the font name of window 1 to "fontname"'
# osascript -e 'tell application "Terminal" to set the font size of window 1 to "fontsize"'
###


if [[ "$OSTYPE" == "darwin"* ]]; then
  # check if ip package is available 
  if ! command -v ip; then
    echo -e '\U1f335 Do you want to install the "ip" package ? (Yy/Nn)'
    echo -e '\U1f335 It it is required for loco.sh to manage vpn connections at startup.'
    if [[ ${choice} == Y|y ]]; then
      brew install iproute2mac
    fi
  fi

  # source startup functions
  . ~/.loco_startup 

  # launch status count
  is_started
fi