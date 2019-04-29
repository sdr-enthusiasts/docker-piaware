#!/bin/sh

ln -s Dockerfile.amd64 Dockerfile
docker build -t mikenye/piaware:3.6.3-amd64 .
rm Dockerfile
