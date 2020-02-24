#!/bin/sh

VERSION=`git rev-parse --abbrev-ref HEAD`
ARCH=`uname -m`
IMAGE=mikenye/piaware

# Make architecture names match docker 'standards' (https://docs.docker.com/docker-for-mac/multi-arch/)
if [ ${ARCH} = "aarch64" ]; then
    ARCH="arm64v8"
fi
if [ ${ARCH} = "x86_64" ]; then
    ARCH="amd64"
fi
if [ ${ARCH} = "armv7l" ]; then
    ARCH="arm32v7"
fi

# Build
echo Building from Dockerfile
docker build -f Dockerfile -t ${IMAGE}:${VERSION}-${ARCH} .

