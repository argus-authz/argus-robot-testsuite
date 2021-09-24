#!/bin/sh

set -xe

if [ -z ${BRANCH_NAME+x} ]; then
  echo "BRANCH_NAME is unset"
  BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
else
  echo "BRANCH_NAME is set to '$BRANCH_NAME'"
fi

echo "Pushing italiangrid/argus-testsuite:${BRANCH_NAME} on dockerhub ..."
docker push italiangrid/argus-testsuite:${BRANCH_NAME}