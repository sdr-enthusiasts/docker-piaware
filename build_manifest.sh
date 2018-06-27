#
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#
docker manifest create mikenye/piaware:latest mikenye/piaware:latest-arm7l mikenye/piaware:latest-x86_64
docker manifest annotate mikenye/piaware:latest mikenye/piaware:latest-x86_64 --os linux --arch amd64
docker manifest annotate mikenye/piaware:latest mikenye/piaware:latest-arm7l --os linux --arch arm --variant v7
docker manifest push mikenye/piaware:latest
