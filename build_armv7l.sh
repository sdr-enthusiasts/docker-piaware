#!/bin/sh

rm Dockerfile
cp Dockerfile.armv7l Dockerfile
docker build -t mikenye/piaware:3.6.3-arm32v7 .
rm Dockerfile
cp Dockerfile.amd64 Dockerfile
