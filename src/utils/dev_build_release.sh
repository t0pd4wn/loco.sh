#!/bin/bash
#-------------------------------------------------------------------------------
# loco_dev_build_release.sh | build a loco release (developer)
#-------------------------------------------------------------------------------

set -eu

function dev_build(){
	local commit_message="${@-}"
	source ./src/utils/clean_profiles.sh
	source ./src/utils/build_release.sh
	git add .
	git commit -m "${commit_message}"
	git push
}

dev_build "${@-}"

set +eu