msg::debug "npm manager"
PACKAGE_MANAGER="npm"
PACKAGE_MANAGER_TEST_CMD='"npm list -g | grep ${PACKAGE}"'
install="install -g"
remove="remove -g"
update="update -g"
upgrade="upgrade -g"