#!/bin/sh

rm Dockerfile
cp Dockerfile.amd64 Dockerfile
docker build -t mikenye/piaware:3.6.3-amd64 .
