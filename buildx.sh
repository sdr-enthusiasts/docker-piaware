#!/bin/sh

REPO=mikenye
IMAGE=piaware

# Build & push latest
docker buildx build -t ${REPO}/${IMAGE}:latest --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 .

# Get piaware version from latest
docker pull mikenye/piaware:latest
VERSION=$(docker run --rm --entrypoint cat ${REPO}/${IMAGE}:latest /VERSIONS | grep piaware | cut -d " " -f 2)

# Build & push version-specific
docker buildx build -t ${REPO}/${IMAGE}:${VERSION} --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 .
