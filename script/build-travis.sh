#!/bin/sh
set -xe

DOCKERFILE=Dockerfile

# Fix $ARG in Dockerfile for docker 1.8 or previous
for ARG in `cat Dockerfile | grep '^ARG ' | awk '{print $2}' | sed ':a;N;$!ba;s/\n/ /g'`
do
  sed -i 's/${'"$ARG"':-//g' $DOCKERFILE
done

sed -i 's/}$//g' $DOCKERFILE
sed -i 's/^ARG.*$//g' $DOCKERFILE
