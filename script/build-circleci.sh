#!/bin/sh
set -xe

if [ -e ~/cache/$CIRCLE_PROJECT_REPONAME.tar ] && [ $(md5sum $DOCKERFILE | cut -d' ' -f1) = $(cat ~/cache/dockerfile.digest) ]
then
  docker load < ~/cache/$CIRCLE_PROJECT_REPONAME.tar
else
  mkdir -p ~/cache
  sudo lxc-attach -n "$(docker build -t $CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME -f $DOCKERFILE .)"
  md5sum Dockerfile | cut -d' ' -f1 > ~/cache/dockerfile.digest
  docker save $CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME > ~/cache/$CIRCLE_PROJECT_REPONAME.tar
fi

docker info
