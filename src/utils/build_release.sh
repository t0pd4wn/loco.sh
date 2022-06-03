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
	zip -FS -r ./dist/loco-dist.zip . -x '*.DS_Store*' \
	-x '/.git*' \
	-x '/src/temp/*' \
	-x '/instances/*' \
	-x '/dist/*'
}

build_release