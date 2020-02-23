#!/bin/sh

VERSION=buildx_test
IMAGE=mikenye/piaware

docker buildx build -t ${IMAGE}:${VERSION} --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64,linux/arm/v6 .

