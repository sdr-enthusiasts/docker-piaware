#
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#

VERSION=3.7.1
IMAGE=mikenye/piaware

docker pull ${IMAGE}:${VERSION}-amd64
docker pull ${IMAGE}:${VERSION}-arm32v7
docker pull ${IMAGE}:${VERSION}-arm64v8

docker manifest create --amend ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-amd64 ${IMAGE}:${VERSION}-arm32v7 ${IMAGE}:${VERSION}-arm64v8
docker manifest annotate ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-amd64 --os linux --arch amd64
docker manifest annotate ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-arm32v7 --os linux --arch arm --variant v7
docker manifest annotate ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-arm64v8 --os linux --arch arm64 --variant v8
docker manifest push --purge ${IMAGE}:${VERSION}

docker manifest create --amend ${IMAGE}:latest ${IMAGE}:${VERSION}-amd64 ${IMAGE}:${VERSION}-arm32v7 ${IMAGE}:${VERSION}-arm64v8
docker manifest annotate ${IMAGE}:latest ${IMAGE}:${VERSION}-amd64 --os linux --arch amd64
docker manifest annotate ${IMAGE}:latest ${IMAGE}:${VERSION}-arm32v7 --os linux --arch arm --variant v7
docker manifest annotate ${IMAGE}:latest ${IMAGE}:${VERSION}-arm64v8 --os linux --arch arm64 --variant v8
docker manifest push --purge ${IMAGE}:latest

