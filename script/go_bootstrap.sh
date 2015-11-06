#!/bin/bash
set -xe

GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz

case "$GOLANG_VERSION" in

  1.4.*)
    GOLANG_DOWNLOAD_SHA1=460caac03379f746c473814a65223397e9c9a2f6
    ;;
  1.5.*)
    GOLANG_DOWNLOAD_SHA1=46eecd290d8803887dec718c691cc243f2175fe0
    ;;
  *)
    exit 1
esac

curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA1  golang.tar.gz" | sha1sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
