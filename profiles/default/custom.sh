#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | profile custom functions (execute as root)
#-------------------------------------------------------------------------------

# macOS related
install_macos_custom_entry(){
    msg::record 'Custom macOS install entry'
    # insert commands below
}

install_macos_custom_exit(){
    msg::record 'Custom macOS install exit'
}

remove_macos_custom_entry(){
    msg::record 'Custom macOS remove entry'
    # insert commands below
}

remove_macos_custom_exit(){
    msg::record 'Custom macOS remove exit'
    # insert commands below
}

# Ubuntu related
install_ubuntu_custom_entry(){
    msg::record 'Custom Ubuntu install entry'
    # insert commands below
}

install_ubuntu_custom_exit(){
    msg::record 'Custom Ubuntu install exit'
    # insert commands below
}

install_ubuntu_custom_last(){
    echo 'Custom Ubuntu install last'
    # insert commands below
}

remove_ubuntu_custom_entry(){
    msg::record 'Custom Ubuntu remove entry'
    # insert commands below
}

remove_ubuntu_custom_exit(){
    msg::record 'Custom Ubuntu remove exit'
    # insert commands below
}

install_last(){
    echo "Bye bye !"
}