#!/bin/sh

set -xe

TAG=${TAG:-"latest"}

docker push italiangrid/argus-testsuite:$TAG
