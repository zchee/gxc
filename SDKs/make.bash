#!/bin/bash

# /Volumes/Xcode/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk

readonly PROGNAME=$(basename $0)
readonly COMMAND=$1
readonly ARG=$2

usage() {
  cat <<EOF
Usage:
  ${PROGNAME} command [arguments...]

Commands:
  build         Build OS X SDK tarball
  list          List OS X SDK versions
  expand        Expand Xcode SDK
EOF
}


debug() {
    is_not_empty $DEBUG && log $@
}

info() {
    echo -e "\033[34m$@\033[m" # blue
}

warn() {
    echo -e "\033[33m$@\033[m" # yellow
}

error() {
    echo -e "\033[31m$@\033[m" # red
}

is_empty() {
    local var=$1

    [[ -z $var ]]
}

is_not_empty() {
    local var=$1

    [[ -n $var ]]
}

is_file() {
    local file=$1

    [[ -f $file ]]
}

is_dir() {
    local dir=$1

    [[ -d $dir ]]
}

build() {
  debug $FUNCNAME $@
  if [[ -d $ARG ]]; then
    if [[ -f ./$ARG.tar.gz ]]; then
      error "exists $ARG.tar.gz in $PWD"
      exit 1
    fi
    info "Creating $ARG.tar.gz..."
    tar zcf $ARG.tar.gz $ARG
  else
    error "$ARG is not directory"
    echo "Please MacOSX*.sdk path."
    echo "e.g."
    echo "    build ./MacOSX10.11.sdk"
  fi
}

list() {
  debug $FUNCNAME $@
}

expand() {
  debug $FUNCNAME $@
  if [[ -f $ARG ]]; then
    info "Mounting $ARG..."
    hdiutil attach -nobrowse "$ARG"
    local XCODE_APP=`ls /Volumes/Xcode/ | grep Xcode`
    local XCODE_VERSION=`ls /Volumes/Xcode/$XCODE_APP/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs`
    if [[ -d ./$XCODE_VERSION ]]; then
      error "exists $XCODE_VERSION in $PWD"
      exit 1
    fi
    info "Copying $XCODE_VERSION..."
    cp -r /Volumes/Xcode/$XCODE_APP/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX*.sdk ./
    info "Ejecting $ARG"
    hdiutil eject /Volumes/Xcode
  else
    error "$ARG is not directory"
    echo "Please Xcode dmg path."
    echo "e.g."
    echo "    expand ~/Downloads/Xcode.dmg"
  fi
}

case "${COMMAND}" in

    build)
        build
        ;;
    list)
        list
        ;;
    expand)
        expand
        ;;

    *)
        error "[Error] Invalid command '${COMMAND}'"
        usage
        # echo "Run '${PROGNAME} help' for usage."
        exit 1
esac

exit 0
