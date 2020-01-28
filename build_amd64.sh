#!/bin/sh

VERSION=3.8.0
IMAGE=mikenye/piaware

docker build -f Dockerfile -t ${IMAGE}:${VERSION} .
