#!/bin/sh

VERSION=3.7.1
IMAGE=mikenye/piaware

docker build -f Dockerfile -t ${IMAGE}:${VERSION} .
