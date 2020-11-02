# mikenye/piaware

FlightAware's PiAware docker container including support for bladeRF, RTLSDR. Includes dump1090-fa (but not yet dump978, see endnote). Builds and runs on `linux/amd64`, `linux/arm/v6`, `linux/arm/v7` and `linux/arm64` (see below).

Can optionally operate in "net only" mode and pull ADS-B data from another host/container running `readsb`/`dump1090`.

For more information on what PiAware is, see here: [FlightAware - PiAware](https://flightaware.com/adsb/piaware/)

*Note:* bladeRF is untested - I don't own bladeRF hardware, but support for the devices is compiled in. If you have bladeRF and this container works for you, please let me know!

## Supported tags and respective Dockerfiles

* `latest` should always contain the latest released versions of `rtl-sdr`, `bladeRF`, `tcllauncher`, `tcllib`, `piaware`, `dump1090`, `mlat-client`, `SoapySDR` and `dump978`. This image is built nightly from the [`master` branch](https://github.com/mikenye/docker-piaware/tree/master) [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/master/Dockerfile) for all supported architectures.
* `development` ([`dev` branch](https://github.com/mikenye/docker-piaware/tree/master), [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/master/Dockerfile), `amd64` architecture only, built on commit, not recommended for production)
* Specific version and architecture tags are available if required, however these are not regularly updated. It is generally recommended to run `latest`.
* There are also `latest` and version-specific tags appended with `_nohealthcheck` where the container healthchecks have been excluded from the image build. See [issue #43](https://github.com/mikenye/docker-piaware/issues/43).

## Contributors

* Thanks to [Jan Collijs](https://github.com/visibilityspots) for contributing to the 3.7.1, 3.7.2 and 3.8.0 releases.
* Thanks to [ShoGinn](https://github.com/ShoGinn) for many contributions to the 3.8.0 release and tidy up of code & readme.

## Multi Architecture Support

Currently, this image should pull and run on the following architectures:

* `linux/amd64`: Built on Linux x86-64
* `linux/arm/v6`: Built on Odroid HC2 running ARMv7 32-bit
* `linux/arm/v7`: Built on Odroid HC2 running ARMv7 32-bit
* `linux/arm64`: Built on a Raspberry Pi 4 Model B running ARMv8 64-bit

## Prerequisites

Before this container will work properly, you must blacklist the kernel modules for the RTL-SDR USB device from the host's kernel.

To do this, create a file `/etc/modprobe.d/blacklist-rtl2832.conf` containing the following:

```shell
# Blacklist RTL2832 so docker container piaware can use the device

blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist rtl2832_sdr
```

Once this is done, you can plug in your RTL-SDR USB device and start the container.

Failure to do this will result in the error below being spammed to the container log.

```log
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

## IMPORTANT

* You need to specify a feeder-id for the container, as this is used by FlightAware to track your PiAware instance.

**Make sure you set your feeder ID via the `FEEDER_ID` environment variable. Failure to do this will cause a new FlightAware site ID to be generated every time you launch the container.**

See below for more info.

## Already running PiAware

You'll need your *feeder-id* from your existing feeder.

To get your *feeder-id*, log onto your feeder and issue the command:

```shell
piaware-config -show feeder-id
```

## New to PiAware

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
$ timeout 30 docker run --rm -e LAT=-33.33333 -e LONG=111.11111 mikenye/piaware:latest | grep "my feeder ID"
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

## Up-and-Running with `docker run` with RTLSDR USB

Firstly, plug in your USB radio.

Run the command `lsusb` and find your radio. It'll look something like this:

```shell
Bus 001 Device 004: ID 0bda:2832 Realtek Semiconductor Corp. RTL2832U DVB-T
```

Take note of the bus number, and device number. In the output above, its 001 and 004 respectively.

Start the docker container, passing through the USB device:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb/USB_BUS_NUMBER/USB_DEVICE_NUMBER \
 -e TZ="YOUR_TIMEZONE" \
 -e LAT=LATITUDE_OF_YOUR_ANTENNA \
 -e LONG=LONGITUDE_OF_YOUR_ANTENNA \
 -p 8080:80 \
 mikenye/piaware
```

For example, based on the `lsusb` output above:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb/001/004 \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -p 8080:80 \
 mikenye/piaware
```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```shell
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```shell
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then re-create your container:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb/001/004 \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 -p 8080:80 \
 mikenye/piaware
```

## Up-and-Running with Docker Compose with RTLSDR USB

Firstly, plug in your USB radio.

Run the command `lsusb` and find your radio. It'll look something like this:

```shell
Bus 001 Device 004: ID 0bda:2832 Realtek Semiconductor Corp. RTL2832U DVB-T
```

Take note of the bus number, and device number. In the output above, its 001 and 004 respectively. This is used in the `devices:` section of the `docker-compose.xml`. Change these in your environment as required.

An example `docker-compose.xml` file is below:

```shell
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    devices:
      - /dev/bus/usb/001/004:/dev/bus/usb/001/004
    ports:
      - 8080:80
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111

```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```shell
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```shell
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then update your `docker-compose.yml` file:

```shell
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    restart: always
    devices:
      - /dev/bus/usb/001/004:/dev/bus/usb/001/004
    ports:
      - 8080:80
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
```

... and issue a `docker-compose up -d` to re-create the container.

## Up-and-Running with `docker run` with external Mode-S/BEAST provider

Start the docker container, passing the hostname (and port if not using 30005) of the external Mode-S/BEAST provider as environment variables:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 -e TZ="YOUR_TIMEZONE" \
 -e LAT=LATITUDE_OF_YOUR_ANTENNA \
 -e LONG=LONGITUDE_OF_YOUR_ANTENNA \
 -e BEASTHOST=beasthost \
 mikenye/piaware
```

For example, based on the `lsusb` output above:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e BEASTHOST=beasthost \
 mikenye/piaware
```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```shell
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```log
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then re-create your container:

```shell
docker run \
 -d \
 --rm \
 --name piaware \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e BEASTHOST=beasthost \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 mikenye/piaware
```

## Up-and-Running with Docker Compose with external Mode-S/BEAST provider

Pass the hostname (and port if not using 30005) of the external Mode-S/BEAST provider as environment variables:

An example `docker-compose.xml` file is below:

```shell
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
      - BEASTHOST=beasthost

```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```shell
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```log
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then update your `docker-compose.yml` file:

```shell
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
      - BEASTHOST=beasthost
      - FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37
```

... and issue a `docker-compose up -d` to re-create the container.

## Runtime Environment Variables

There are a series of available environment variables:

| Environment Variable | Purpose                         | Default |
| -------------------- | ------------------------------- | ------- |
| `LAT`                | Antenna's latitude (required)   |         |
| `LONG`               | Antenna's longitude (required)  |         |
| `TZ`                 | Your local timezone (optional)  | GMT     |
| `DUMP1090_DEVICE`    | Select RTL-SDR device by index or serial number (optional)  | |
| `ALLOW_MLAT`         | Used for setting `piaware-config` variable `allow-mlat` (optional) | yes |
| `ALLOW_MODEAC`       | Used for setting `piaware-config` variable `allow-modeac` (optional) | yes |
| `RTLSDR_PPM`         | Used for setting `piaware-config` variable `rtlsdr-ppm` (optional) | 0 |
| `RTLSDR_GAIN`        | Optimizing gain (optional) -- See [FlightAware -- Optimizing Gain](https://discussions.flightaware.com/t/thoughts-on-optimizing-gain/44482/2) | -10 (max)|
| `BEASTHOST`          | Optional. IP/Hostname of a Mode-S/BEAST provider (dump1090/readsb). If given, no USB device needs to be passed through to the container. | |
| `BEASTPORT`          | Optional. TCP port number of Mode-S/BEAST provider (dump1090/readsb). | 30005 |
| `FEEDER_ID`          | Your FlightAware feeder ID (required) | |
| `BINGMAPSAPIKEY`     | Optional. Bing Maps API Key. If set, it is configured in `dump1090`'s `config.js`. | |
| `VERBOSE_LOGGING`    | Optional. Set to `true` for more verbose logs. | |

For an explanation of `piaware-config` variables, see [FlightAware PiAware Advanced Configuration](https://flightaware.com/adsb/piaware/advanced_configuration).

## Ports

The following ports are used by this container:

* `80` - PiAware Status page and dump1090 web interface (Skyaware) - optional but recommended so you can check status and and watch the planes fly around.
* `8080` - dump1090 web interface (Skyaware) only. If you just want the map, you can use this instead of port `80`.
* `30001` - dump1090 TCP raw input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30002` - dump1090 TCP raw output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30003` - dump1090 TCP BaseStation output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30004` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30005` - dump1090 TCP Beast output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30104` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed

## Claiming

Since version 3.8.0 the `flightaware-user` and `flightaware-password` configuration options are no longer used; please use the normal site-claiming mechanisms to associate sites with a FlightAware account.

[FlightAware PiAware Claim](https://flightaware.com/adsb/piaware/claim)

## Feed to other services

Check out the images:

* [mikenye/adsbexchange](https://hub.docker.com/r/mikenye/adsbexchange)
* [mikenye/fr24feed](https://hub.docker.com/r/mikenye/fr24feed)
* [mikenye/readsb](https://hub.docker.com/repository/docker/mikenye/readsb)

## Logging

* All processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.
* `lighttpd` (which provides SkyAware & SkyAware978) is configured to not log (except for a startup message on container start)

## Note about dump978

`dump978` and its prerequisites (SoapySDR) compile in this docker image, however I don't have a suitable RTLSDR radio I can use to test this with. The FlightAware Pro Stick Plus Blue that I own has a 1090MHz bandpass filter built in, so it is basically useless for 978MHz. Furthermore, 978MHz is not yet used by aircraft in Australia. If anyone lives where 978MHz is used and wants to work on this project to include support for dump978, please get in touch! If you're interested in testing this yourself, the `dump978` binaries provided by [flightaware/dump978](https://github.com/flightaware/dump978) are included in the image, but for now you will have to run them manually.

* `/usr/local/bin/dump978-fa`
* `/usr/lib/piaware/helpers/faup978`
* `/usr/local/bin/skyaware978`

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-piaware/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.

## Changelog

See the project's [commit history](https://github.com/mikenye/docker-piaware/commits/master).
