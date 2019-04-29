#!/bin/sh

ln -s Dockerfile.armv7l Dockerfile
docker build -t mikenye/piaware:3.6.3-arm32v7 .
rm Dockerfile
