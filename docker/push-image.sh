#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm114.cloud.cnaf.infn.it"}
TAG=${TAG:-"latest"}

image_name=italiangrid/argus-testsuite:$TAG
dest=${DOCKER_REGISTRY_HOST}/$image_name
	
docker tag $image_name $dest
docker push $dest
