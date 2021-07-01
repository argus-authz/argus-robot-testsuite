#!/bin/bash

set -xe

if [ -z ${BRANCH_NAME+x} ]; then
  echo "BRANCH_NAME is unset"
  BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
else
  echo "BRANCH_NAME is set to '$BRANCH_NAME'"
fi

docker build --no-cache -t italiangrid/argus-testsuite:${BRANCH_NAME} .