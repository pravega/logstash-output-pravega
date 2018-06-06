#!/bin/sh
set -u

PRAVEGA_SCOPE=${PRAVEGA_SCOPE:-examples}
PRAVEGA_STREAM=${PRAVEGA_STREAM:-apacheaccess}
CONTAINER_NAME=pravega
IMAGE_NAME=pravega-demo

docker rm -f ${CONTAINER_NAME}

docker run -d --name $CONTAINER_NAME \
    -p 9090:9090 \
    -p 9091:9091 \
    -p 9600:9600 \
    -v ${PWD}/access.log:/opt/data/access.log \
    -v ${PWD}/logs:/var/log/pravega \
    -e PRAVEGA_SCOPE=${PRAVEGA_SCOPE} \
    -e PRAVEGA_STREAM=${PRAVEGA_STREAM} \
    ${IMAGE_NAME}
