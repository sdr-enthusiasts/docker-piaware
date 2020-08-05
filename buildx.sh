#!/usr/bin/env sh

REPO=mikenye
IMAGE=piaware
PLATFORMS="linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build & push latest
docker buildx build -t ${REPO}/${IMAGE}:latest --no-cache --compress --push --platform "${PLATFORMS}" .

# Get piaware version from latest
docker pull ${REPO}/${IMAGE}:latest
VERSION=$(docker run --rm --entrypoint cat ${REPO}/${IMAGE}:latest /VERSIONS | grep piaware | cut -d " " -f 2)

# Build & push version-specific
docker buildx build -t "${REPO}/${IMAGE}:${VERSION}" --compress --push --platform "${PLATFORMS}" .

# BUILD NOHEALTHCHECK VERSION
# Modify dockerfile to remove healthcheck
sed '/^HEALTHCHECK /d' < Dockerfile > Dockerfile.nohealthcheck

# Build & push latest
docker buildx build -f Dockerfile.nohealthcheck -t ${REPO}/${IMAGE}:latest_nohealthcheck --compress --push --platform "${PLATFORMS}" .

# Build & push version-specific
docker buildx build -f Dockerfile.nohealthcheck -t "${REPO}/${IMAGE}:${VERSION}_nohealthcheck" --compress --push --platform "${PLATFORMS}" .
