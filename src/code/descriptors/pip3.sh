msg::debug "pip3 manager"
PACKAGE_MANAGER="pip3"
PACKAGE_MANAGER_TEST_CMD='"pip3 list | grep -F ${PACKAGE}"'
install="install"
remove="uninstall --yes"
update="download"
upgrade="install"
