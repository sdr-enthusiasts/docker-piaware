#
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#

docker manifest create mikenye/piaware:3.6.3 mikenye/piaware:3.6.3-amd64 mikenye/piaware:3.6.3-arm32v7
docker manifest annotate mikenye/piaware:3.6.3 mikenye/piaware:3.6.3-amd64 --os linux --arch amd64
docker manifest annotate mikenye/piaware:3.6.3 mikenye/piaware:3.6.3-arm32v7 --os linux --arch arm --variant v7
docker manifest push mikenye/piaware:3.6.3

docker manifest create --amend mikenye/piaware:latest mikenye/piaware:3.6.3-amd64 mikenye/piaware:3.6.3-arm32v7
docker manifest annotate mikenye/piaware:latest mikenye/piaware:3.6.3-amd64 --os linux --arch amd64
docker manifest annotate mikenye/piaware:latest mikenye/piaware:3.6.3-arm32v7 --os linux --arch arm --variant v7
docker manifest push mikenye/piaware:latest

