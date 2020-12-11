#!/usr/bin/env sh

# Get the latest version of the image
VERSION_TAG=$(docker run --rm --entrypoint cat ${REPO}/${IMAGE}:latest /VERSIONS | grep piaware | cut -d " " -f 2)

# Set github action environment variable VERSION_TAG
echo “::set-env name=VERSION_TAG::$VERSION_TAG”
