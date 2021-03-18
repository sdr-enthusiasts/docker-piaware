# mikenye/piaware

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mikenye/docker-piaware/Deploy%20to%20Docker%20Hub)](https://github.com/mikenye/docker-piaware/actions?query=workflow%3A%22Deploy+to+Docker+Hub%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/mikenye/piaware.svg)](https://hub.docker.com/r/mikenye/piaware)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mikenye/piaware/latest)](https://hub.docker.com/r/mikenye/piaware)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

FlightAware's PiAware docker container including support for RTL-SDR, bladeRF and others. Includes `dump1090` and `dump978`.

Builds and runs on `linux/amd64`, `linux/386`, `linux/arm/v6`, `linux/arm/v7` and `linux/arm64`.

For more information on what PiAware is, see here: [FlightAware - PiAware](https://flightaware.com/adsb/piaware/).

This container can operate in "net only" mode and pull ADS-B Mode-S & UAT data from another host/container. **This is the recommended way of deploying the container**, and I'd humbly suggest [`mikenye/readsb-protobuf`](https://github.com/mikenye/docker-readsb-protobuf) and [`mikenye/dump978`](https://github.com/mikenye/docker-dump978) (if you live in an area that uses UAT).

*Note:* `bladerf`/`hackrf`/`limesdr`/`radarcape` - Support for these is compiled in, but I need to complete the wrapper/helper scripts. I don't have access to these devices. If you do, and would be willing to test, please get in touch with me!

## Table of Contents

* [mikenye/piaware](#mikenyepiaware)
  * [Table of Contents](#table-of-contents)
  * [Supported tags and respective Dockerfiles](#supported-tags-and-respective-dockerfiles)
  * [Contributors](#contributors)
  * [Multi Architecture Support](#multi-architecture-support)
  * [Prerequisites](#prerequisites)
  * [Determining your Feeder ID](#determining-your-feeder-id)
    * [Already running PiAware](#already-running-piaware)
    * [New to PiAware](#new-to-piaware)
  * [Deployment Examples](#deployment-examples)
    * [Example `docker run` command with RTL-SDR USB for reception of 1090MHz](#example-docker-run-command-with-rtl-sdr-usb-for-reception-of-1090mhz)
    * [Example `docker-compose.yml` with RTL-SDR USB for reception of 1090MHz](#example-docker-composeyml-with-rtl-sdr-usb-for-reception-of-1090mhz)
    * [Example `docker run` command with 2x RTL-SDR USB for reception of 1090MHz and 978MHz](#example-docker-run-command-with-2x-rtl-sdr-usb-for-reception-of-1090mhz-and-978mhz)
    * [Example `docker-compose.yml` with 2x RTL-SDR USB for reception of 1090MHz and 978MHz](#example-docker-composeyml-with-2x-rtl-sdr-usb-for-reception-of-1090mhz-and-978mhz)
    * [Example `docker run` with external Mode-S/BEAST provider](#example-docker-run-with-external-mode-sbeast-provider)
    * [Example `docker-compose.yml` with external Mode-S/BEAST provider](#example-docker-composeyml-with-external-mode-sbeast-provider)
    * [Example `docker run` with external Mode-S/BEAST provider and external UAT provider](#example-docker-run-with-external-mode-sbeast-provider-and-external-uat-provider)
    * [Example `docker-compose.yml` with external Mode-S/BEAST provider and external UAT provider](#example-docker-composeyml-with-external-mode-sbeast-provider-and-external-uat-provider)
  * [Environment Variables](#environment-variables)
    * [General](#general)
    * [Multilateration](#multilateration)
    * [Receiver Configuration (1090MHz)](#receiver-configuration-1090mhz)
    * [RTL-SDR Configuration (1090MHz)](#rtl-sdr-configuration-1090mhz)
    * [Relay Configuration (1090MHz)](#relay-configuration-1090mhz)
    * [Receiver Configuration (987MHz)](#receiver-configuration-987mhz)
    * [RTL-SDR Configuration (978MHz)](#rtl-sdr-configuration-978mhz)
    * [Relay Configuration (978MHz)](#relay-configuration-978mhz)
  * [Ports](#ports)
  * [Claiming Your Receiver](#claiming-your-receiver)
  * [Logging](#logging)
  * [Other services to feed](#other-services-to-feed)
  * [Getting help](#getting-help)
  * [Changelog](#changelog)

## Supported tags and respective Dockerfiles

* `latest` should always contain the latest released version of piaware and support tools. This image is built nightly from the [`master` branch](https://github.com/mikenye/docker-piaware/tree/master) [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/master/Dockerfile) for all supported architectures.
* Specific version and architecture tags are available if required, however these are not regularly updated. It is generally recommended to run `latest`.
* There are also `latest` and version-specific tags appended with `_nohealthcheck` where the container healthchecks have been excluded from the image build. See [issue #43](https://github.com/mikenye/docker-piaware/issues/43).

## Contributors

* Thanks to [Jan Collijs](https://github.com/visibilityspots) for contributing to the 3.7.1, 3.7.2 and 3.8.0 releases.
* Thanks to [ShoGinn](https://github.com/ShoGinn) for many contributions to the 3.8.0 release and tidy up of code & readme.
* Thanks to [ssbb](https://flightaware.com/adsb/stats/user/pmd5700#stats-134107) for allowing me to use his Pi as a development platform for UAT support.

## Multi Architecture Support

Currently, this image should pull and run on the following architectures:

* `linux/amd64`: Built on Linux x86-64
* `linux/arm/v6`: Built on Odroid HC2 running ARMv7 32-bit
* `linux/arm/v7`: Built on Odroid HC2 running ARMv7 32-bit
* `linux/arm64`: Built on a Raspberry Pi 4 Model B running ARMv8 64-bit

## Prerequisites

If using an RTL-SDR, before this container will work properly, you must blacklist the kernel modules for the RTL-SDR USB device from the host's kernel.

To do this, create a file `/etc/modprobe.d/blacklist-rtl2832.conf` containing the following:

```shell
# Blacklist RTL2832 so docker container piaware can use the device

blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist rtl2832_sdr
```

Once this is done, you can plug in your RTL-SDR USB device and start the container.

Failure to do this will result in the error below being spammed to the container log.

```text
2019-04-29 21:14:31.642500500  [dump1090-fa] Kernel driver is active, or device is claimed by second instance of librtlsdr.
2019-04-29 21:14:31.642635500  [dump1090-fa] In the first case, please either detach or blacklist the kernel module
2019-04-29 21:14:31.642663500  [dump1090-fa] (dvb_usb_rtl28xxu), or enable automatic detaching at compile time.
2019-04-29 21:14:31.642677500  [dump1090-fa]
2019-04-29 21:14:31.642690500  [dump1090-fa] usb_claim_interface error -6
```

If you get the error above even after blacklisting the kernel modules as outlined above, the modules may still be loaded. You can unload them by running the following commands:

```shell
sudo rmmod rtl2832_sdr
sudo rmmod dvb_usb_rtl28xxu
sudo rmmod rtl2832
```

## Determining your Feeder ID

You need to specify a feeder-id for the container, as this is used by FlightAware to track your PiAware instance.

**Make sure you set your feeder ID via the `FEEDER_ID` environment variable. Failure to do this will cause a new FlightAware site ID to be generated every time you launch the container.**

### Already running PiAware

You'll need your *feeder-id* from your existing feeder.

To get your *feeder-id*, log onto your feeder and issue the command:

```shell
piaware-config -show feeder-id
```

### New to PiAware

You'll need a *feeder-id*. To get one, you can temporarily run the container, to allow it to communicate with the FlightAware servers and get a new feeder ID.

Run the commands:

```shell
docker pull mikenye/piaware:latest
timeout 60 docker run --rm -e LAT=YOURLATITUDE -e LONG=YOURLONGITUDE mikenye/piaware:latest | grep "my feeder ID"
```

Be sure to change the following:

* Replace `YOURLATITUDE` with the latitude of your antenna (xx.xxxxx)
* Replace `YOURLONGITUDE` with the longitude of your antenna (xx.xxxxx)

The command will run the container for 30 seconds, which should be ample time for the container to receive a feeder-id.

For example:

```shell
timeout 30 docker run --rm -e LAT=-33.33333 -e LONG=111.11111 mikenye/piaware:latest | grep "my feeder ID"
```

Will output:

```text
Set allow-mlat to yes in /etc/piaware.conf:1
Set allow-modeac to yes in /etc/piaware.conf:2
Set allow-auto-updates to no in /etc/piaware.conf:3
Set allow-manual-updates to no in /etc/piaware.conf:4
2020-03-06 06:16:11.860212500  [piaware] my feeder ID is acbf1f88-09a4-3a47-a4a0-10ae138d0c1g
write /dev/stdout: broken pipe
Terminated
```

As you can see from the output above, the feeder-id given to us from FlightAware is `acbf1f88-09a4-3a47-a4a0-10ae138d0c1g`.

You'll now want to "claim" this feeder.

To do this, go to: [FlightAware PiAware Claim](https://flightaware.com/adsb/piaware/claim) and follow the instructions there.

## Deployment Examples

### Example `docker run` command with RTL-SDR USB for reception of 1090MHz

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 -e RECEIVER_TYPE=rtlsdr \
 -p 8080:80 \
 --tmpfs=/run:exec,size=64M \
 --tmpfs=/var/log \
 mikenye/piaware
```

### Example `docker-compose.yml` with RTL-SDR USB for reception of 1090MHz

```yaml
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    devices:
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - 8080:80
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
      - RECEIVER_TYPE=rtlsdr
    tmpfs:
      - /run:exec,size=64M
      - /var/log
```

### Example `docker run` command with 2x RTL-SDR USB for reception of 1090MHz and 978MHz

This will currently only work in the United States of America, as they are the only country that uses ADS-B UAT on 978MHz.

This example assumes that:

* Your 1090MHz RTL-SDR has its serial set to `00001090`
* Your 978MHz RTL-SDR has its serial set to `00000978`

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e RECEIVER_TYPE=rtlsdr \
 -e DUMP1090_DEVICE=00001090 \
 -e UAT_RECEIVER_TYPE=rtlsdr \
 -e DUMP978_DEVICE=00000978 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 -p 8080:80 \
 --tmpfs=/run:exec,size=64M \
 --tmpfs=/var/log \
 mikenye/piaware
```

### Example `docker-compose.yml` with 2x RTL-SDR USB for reception of 1090MHz and 978MHz

This will currently only work in the United States of America, as they are the only country that uses ADS-B UAT on 978MHz.

```yaml
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    devices:
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - 8080:80
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
      - RECEIVER_TYPE=rtlsdr
      - DUMP1090_DEVICE=00001090
      - UAT_RECEIVER_TYPE=rtlsdr
      - DUMP978_DEVICE=00000978
    tmpfs:
      - /run:exec,size=64M
      - /var/log
```

### Example `docker run` with external Mode-S/BEAST provider

An example of an external Mode-S/BEAST provider would be:

* [`mikenye/readsb-protobuf`](https://github.com/mikenye/docker-readsb-protobuf) container
* Another hardware feeder that provides BEAST output data on port 30005

In the example below, it is assumed that the external BEAST provider resolves to `beasthost` and is listening for connections on TCP port `30005`.

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e RECEIVER_TYPE=relay \
 -e BEASTHOST=beasthost \
 -e BEASTPORT=30005 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 --tmpfs=/run:exec,size=64M \
 --tmpfs=/var/log \
 mikenye/piaware
```

### Example `docker-compose.yml` with external Mode-S/BEAST provider

An example of an external Mode-S/BEAST provider would be:

* [`mikenye/readsb-protobuf`](https://github.com/mikenye/docker-readsb-protobuf) container
* Another hardware feeder that provides BEAST output data on port 30005

In the example below, it is assumed that the external BEAST provider resolves to `beasthost` and is listening for connections on TCP port `30005`.

```yaml
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
      - RECEIVER_TYPE=relay
      - BEASTHOST=beasthost
      - BEASTPORT=30005
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
    tmpfs:
      - /run:exec,size=64M
      - /var/log
```

### Example `docker run` with external Mode-S/BEAST provider and external UAT provider

This will currently only work in the United States of America, as they are the only country that uses ADS-B UAT on 978MHz.

An example of an external Mode-S/BEAST provider would be:

* [`mikenye/readsb-protobuf`](https://github.com/mikenye/docker-readsb-protobuf) container
* Another hardware feeder that provides BEAST output data on port 30005

In the example below, it is assumed that the external BEAST provider resolves to `beasthost` and is listening for connections on TCP port `30005`.

An example of an external UAT provider would be:

* [`mikenye/dump978`](https://github.com/mikenye/docker-dump978) container

In the example below, it is assumed that the external UAT provider resolves to `uathost` and is listening for connections on TCP port `30978`.

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e RECEIVER_TYPE=relay \
 -e BEASTHOST=beasthost \
 -e BEASTPORT=30005
 -e UAT_RECEIVER_TYPE=relay \
 -e UAT_RECEIVER_HOST=uathost \
 -e UAT_RECEIVER_PORT=30978 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 --tmpfs=/run:exec,size=64M \
 --tmpfs=/var/log \
 mikenye/piaware
```

### Example `docker-compose.yml` with external Mode-S/BEAST provider and external UAT provider

This will currently only work in the United States of America, as they are the only country that uses ADS-B UAT on 978MHz.

An example of an external Mode-S/BEAST provider would be:

* [`mikenye/readsb-protobuf`](https://github.com/mikenye/docker-readsb-protobuf) container
* Another hardware feeder that provides BEAST output data on port 30005

In the example below, it is assumed that the external BEAST provider resolves to `beasthost` and is listening for connections on TCP port `30005`.

An example of an external UAT provider would be:

* [`mikenye/dump978`](https://github.com/mikenye/docker-dump978) container

In the example below, it is assumed that the external UAT provider resolves to `uathost` and is listening for connections on TCP port `30978`.

```yaml
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
      - RECEIVER_TYPE=relay
      - BEASTHOST=beasthost
      - BEASTPORT=30005
      - UAT_RECEIVER_TYPE=relay
      - UAT_RECEIVER_HOST=uathost
      - UAT_RECEIVER_PORT=30978
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
    tmpfs:
      - /run:exec,size=64M
      - /var/log
```

## Environment Variables

For an explanation of `piaware-config` variables, see [FlightAware PiAware Advanced Configuration](https://flightaware.com/adsb/piaware/advanced_configuration).

### General

| Environment Variable | Purpose                         | Default |
| -------------------- | ------------------------------- | ------- |
| `TZ` | Local timezone in ["TZ database name" format](<https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>). | `UTC` |
| `FEEDER_ID`          | Your FlightAware feeder ID (required) | |
| `BINGMAPSAPIKEY`     | Optional. Bing Maps API Key. If set, it is configured in `dump1090`'s `config.js`. | |
| `VERBOSE_LOGGING`    | Optional. Set to `true` for more verbose logs. | |

### Multilateration

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `ALLOW_MLAT` | `yes` or `no` | If `yes`, multilateration is enabled (also requires that receiver location is set on the FlightAware My ADS-B stats page) | `yes` |
| `MLAT_RESULTS` | `yes` or `no` | If `yes`, multilateration results are returned to PiAware from FlightAware | `yes` |

### Receiver Configuration (1090MHz)

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `ALLOW_MODEAC` | `yes` or `no` | If `yes`, piaware and dump1090-fa will enable Mode A/C decoding if a client requests it.
Mode A/C decoding requires additional CPU when enabled. | `yes` |
| `RECEIVER_TYPE` | `rtlsdr`, `relay` | Configures how PiAware attempts to talk to the ADS-B receiver | `rtlsdr` |

Receiver types:

* `rtlsdr` - For FlightAware dongles and any other RTL-SDR
* `relay` - For use with an external BEAST protocol provider running on another host (dump1090/readsb/etc)
* `bladerf`/`hackrf`/`limesdr`/`radarcape` - Support for these is compiled in, but I need to complete the wrapperr scripts. I don't have access to these devices. If you do, and would be willing to test, please get in touch with me!

### RTL-SDR Configuration (1090MHz)

Use only with `RECEIVER_TYPE=rtlsdr`.

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `RTLSDR_PPM`   | a frequency correction in PPM | Configures the dongle PPM correction | `0` |
| `RTLSDR_GAIN`  | `max` or a numeric gain level | Optimizing gain (optional) -- See [FlightAware -- Optimizing Gain](https://discussions.flightaware.com/t/thoughts-on-optimizing-gain/44482/2) | `max` |
| `DUMP1090_DEVICE` | rtlsdr device serial number | Configures which dongle to use for 1090MHz reception if there is more than one connected | first available device |

### Relay Configuration (1090MHz)

Use only with `RECEIVER_TYPE=relay`.

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `BEASTHOST` | a hostname or IP | Specify an external BEAST protocol provider (dump1090/readsb/etc). | |
| `BEASTPORT` | a port number | Specify the TCP port number of the external BEAST protocol provider. | `30005` |

### Receiver Configuration (987MHz)

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `UAT_RECEIVER_TYPE`  | `none`, `rtlsdr`, `relay` | Configures how PiAware attempts to talk to the ADS-B receiver | `none` |

Receiver types:

* `rtlsdr` - For FlightAware dongles and any other RTL-SDR
* `relay` - For use with an external BEAST protocol provider running on another host (dump1090/readsb/etc)
* `bladerf`/`hackrf`/`limesdr`/`radarcape` - Support for these is compiled in, but I need to complete the wrapperr scripts. I don't have access to these devices. If you do, and would be willing to test, please get in touch with me!

### RTL-SDR Configuration (978MHz)

Use only with `UAT_RECEIVER_TYPE=rtlsdr`.

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `DUMP978_DEVICE` | rtlsdr device serial number | Configures which dongle to use for 978MHz reception if there is more than one connected | first available device |
| `UAT_SDR_GAIN`       | `max` or a numeric gain level | Optimizing gain (optional) -- See [FlightAware -- Optimizing Gain](https://discussions.flightaware.com/t/thoughts-on-optimizing-gain/44482/2) | `max` |
| `UAT_SDR_PPM`        | a frequency correction in PPM | Configures the dongle PPM correction | `0` |

### Relay Configuration (978MHz)

Use only with `UAT_RECEIVER_TYPE=relay`.

| Environment Variable | Possible Values | Description | Default |
| -------------------- | --------------- | ------- | ------- |
| `UAT_RECEIVER_HOST`  | a hostname or IP | Specify an external UAT raw data provider (dump978-fa). | |
| `UAT_RECEIVER_PORT`  | a port number | Specify the TCP port number of the external UAT raw data provider. | `30978` |

## Ports

The following ports are used by this container:

* `80` - PiAware Status page and dump1090 web interface (Skyaware) - optional but recommended so you can check status and and watch the planes fly around.
* `30003` - dump1090 TCP BaseStation output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30005` - dump1090 TCP Beast output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30105` - If MLAT is enabled, `mlat-client` results published on this port in Beast format - optional, recommended to leave unmapped unless explicitly needed
* `30978` - If UAT decoding is enabled, UAT raw data published on this port - optional, recommended to leave unmapped unless explicitly needed
* `30979` - If UAT decoding is enabled, UAT decoded JSON published on this port - optional, recommended to leave unmapped unless explicitly needed

## Claiming Your Receiver

Since version 3.8.0 the `flightaware-user` and `flightaware-password` configuration options are no longer used; please use the normal site-claiming mechanisms to associate sites with a FlightAware account.

[FlightAware PiAware Claim](https://flightaware.com/adsb/piaware/claim)

## Logging

* All processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.
* `lighttpd` (which provides SkyAware & SkyAware978) is configured to not log (except for a startup message on container start)

## Other services to feed

Check out these other images:

* [`mikenye/adsbexchange`](https://hub.docker.com/r/mikenye/adsbexchange) to feed ADSB data to [adsbexchange.com](https://adsbexchange.com)
* [`mikenye/adsbhub`](https://hub.docker.com/r/mikenye/adsbhub) to feed ADSB data into [adsbhub.org](https://adsbhub.org/)
* [`mikenye/fr24feed`](https://hub.docker.com/r/mikenye/fr24feed) to feed ADSB data into [flightradar24.com](https://www.flightradar24.com)
* [`mikenye/radarbox`](https://hub.docker.com/r/mikenye/radarbox) to feed ADSB data into [radarbox.com](https://www.radarbox.com)
* [`mikenye/opensky-network`](https://hub.docker.com/r/mikenye/opensky-network) to feed ADSB data into [opensky-network.org](https://opensky-network.org/)
* [`mikenye/planefinder`](https://hub.docker.com/r/mikenye/planefinder) to feed ADSB data into [planefinder.net](https://planefinder.net/)

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-piaware/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.

## Changelog

See the project's [commit history](https://github.com/mikenye/docker-piaware/commits/master).
