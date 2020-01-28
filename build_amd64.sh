#!/bin/sh

VERSION=3.7.2
IMAGE=mikenye/piaware

docker build -f Dockerfile -t ${IMAGE}:${VERSION} .
