# sdr-enthusiasts/docker-piaware

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mikenye/piaware/latest)](https://hub.docker.com/r/mikenye/piaware)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

FlightAware's PiAware docker container including support for RTL-SDR, bladeRF and others. Includes `dump1090` and `dump978`.

Builds and runs on `linux/amd64`, `linux/386`, `linux/arm/v7` and `linux/arm64`.

For more information on what PiAware is, see here: [FlightAware - PiAware](https://flightaware.com/adsb/piaware/).

This container can operate in "net only" mode and pull ADS-B Mode-S & UAT data from another host/container. **This is the recommended way of deploying the container**, and I'd humbly suggest [`sdr-enthusiasts/docker-readsb-protobuf`](https://github.com/sdr-enthusiasts/docker-readsb-protobuf) and [`sdr-enthusiasts/docker-dump978`](https://github.com/sdr-enthusiasts/docker-dump978) (if you live in an area that uses UAT).

*Note:* `bladerf`/`hackrf`/`limesdr`/`radarcape` - Support for these is compiled in, but I need to complete the wrapper/helper scripts. I don't have access to these devices. If you do, and would be willing to test, please get in touch with me!

## Documentation

Please [read this container's detailed and thorough documentation in the GitHub repository.](https://github.com/sdr-enthusiasts/docker-piaware/blob/main/README.md)