#
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#

VERSION=3.7.1

docker pull mikenye/piaware:${VERSION}-amd64
docker pull mikenye/piaware:${VERSION}-arm32v7

docker manifest create --amend mikenye/piaware:${VERSION} mikenye/piaware:${VERSION}-amd64 mikenye/piaware:${VERSION}-arm32v7
docker manifest annotate mikenye/piaware:${VERSION} mikenye/piaware:${VERSION}-amd64 --os linux --arch amd64
docker manifest annotate mikenye/piaware:${VERSION} mikenye/piaware:${VERSION}-arm32v7 --os linux --arch arm --variant v7
docker manifest push --purge mikenye/piaware:${VERSION}

docker manifest create --amend mikenye/piaware:latest mikenye/piaware:${VERSION}-amd64 mikenye/piaware:${VERSION}-arm32v7
docker manifest annotate mikenye/piaware:latest mikenye/piaware:${VERSION}-amd64 --os linux --arch amd64
docker manifest annotate mikenye/piaware:latest mikenye/piaware:${VERSION}-arm32v7 --os linux --arch arm --variant v7
docker manifest push --purge mikenye/piaware:latest

