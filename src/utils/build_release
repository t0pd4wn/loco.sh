#!/bin/bash
#-------------------------------------------------------------------------------
# loco_build_release.sh | build a loco release
#-------------------------------------------------------------------------------

set -eu

#######################################
# Build a zip file from folder root
# Output:
#   dist/loco-dist.zip
#######################################
build_release(){
	if ! sudo rm -fr ./src/temp/*; then
		echo "Can not remove temp files" >&2
	fi
	zip -FS -r ./dist/loco-dist.zip . \
	-x '*.DS_Store*' \
	-x '/.git*' \
	-x '/instances/*' \
	-x '/dist/*'
}

build_release

set +eu