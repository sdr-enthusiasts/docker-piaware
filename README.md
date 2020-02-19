# docker-piaware
FlightAware's PiAware docker container including support for bladeRF, RTLSDR. Includes dump1090-fa (but not yet dump978, see endnote). Builds and runs on x86_64, arm32v7 and arm64v8 (see below).

Can optionally pull Mode-S/BEAST data from another host/container running `readsb`/`dump1090`.

For more information on what PiAware is, see here: https://flightaware.com/adsb/piaware/

Tested and working on:
 * `x86_64` (`amd64`) platform running Ubuntu 16.04.4 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * `armv7l` (`arm32v7`) platform (Odroid HC1) running Ubuntu 18.04.1 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * `aarch64` (`arm64v8`) platform (Raspberry Pi 4) running Raspbian Buster 64-bit using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * If you run on a different platform (or if you have issues) please raise an issue and let me know!
 * bladeRF is untested - I don't own bladeRF hardware, but support for the devices is compiled in. If you have bladeRF and this container works for you, please let me know!

## Supported tags and respective Dockerfiles
* `latest`, `3.8.0_1`
  * `latest-amd64`, `3.8.0_1-amd64` (`3.8.0_1` branch, `Dockerfile.amd64`)
  * `latest-arm32v7`, `3.8.0_1-arm32v7` (`3.8.0_1` branch, `Dockerfile.arm32v7`)
  * `latest-arm64v8`, `3.8.0_1-arm64v8` (`3.8.0_1` branch, `Dockerfile.arm64v8`)
* `3.8.0`
  * `3.8.0-amd64` (`3.8.0` branch, `Dockerfile.amd64`)
  * `3.8.0-arm32v7` (`3.8.0` branch, `Dockerfile.arm32v7`)
  * `3.8.0-arm64v8` (`3.8.0` branch, `Dockerfile.arm64v8`)
* `3.7.2`
  * `3.7.2-amd64` (`3.7.2` branch, `Dockerfile.amd64`)
  * `3.7.2-arm32v7` (`3.7.2` branch, `Dockerfile.arm32v7`)
  * `3.7.2-arm64v8` (`3.7.2` branch, `Dockerfile.arm64v8`)
* `3.7.1`
  * `3.7.1-amd64` (`3.7.1` branch, `Dockerfile.amd64`)
  * `3.7.1-arm32v7` (`3.7.1` branch, `Dockerfile.armv7l`)
  * `3.7.1-arm64v8` (`3.7.1` branch, `Dockerfile.aarch64`)
* `3.6.3`
  * `3.6.3-amd64` (`3.6.3` branch, `Dockerfile.amd64`)
  * `3.6.3-arm32v7` (`3.6.3` branch, `Dockerfile.armv7l`)
* `3.5.3`
  * `3.5.3-amd64` (`3.5.3` branch, `Dockerfile`)
  * `3.5.3-arm32v7` (`3.5.3` branch, `Dockerfile`)
* `development` (`master` branch, `Dockerfile`, `amd64` architecture only, not recommended for production)

## Contributors
 * Thanks to [Jan Collijs](https://github.com/visibilityspots) for contributing to the 3.7.1, 3.7.2 and 3.8.0 releases.

## Changelog

### v3.8.0_1
 * Added `BEASTHOST` and `BEASTPORT` variables to allow pulling of ModeS/BEAST data from another host/container (for example `mikenye/readsb`). If given, there is no need to pass the RTLSDR USB device through to the container.

### v3.8.0
 * Update piaware to v3.8.0 
 * Update tcllauncher to v1.10
 * Update mlatclient to v0.2.11
 * Update tcllib to v1.20
 * Removed deprecated flightaware user/password options
 * Added FEEDER_ID parameter to be able to run without persistant storage

### v3.7.2
 * Update piaware to v3.7.2

### v3.7.1
 * Update piaware to v3.7.1
 * Add support for `arm64v8` / `aarch64` architecture
 * Add support for gain optimisation (thanks [Jan Collijs](https://github.com/visibilityspots)!) 

### v3.6.3
 * Update piaware to v3.6.3
 * Reduction of image size 663MB down to 304MB
    * Change base image to Alpine v3.9
    * Reduce build layers
    * The "unoptimised" version of the Dockerfile is available in the source repo for educational/troubleshooting purposes
 * Implement s6-overlay for process supervision
 * Make logging much better
 * bladeRF is supported again (my first release of 3.6.3 dropped support for bladeRF, but since then I've overcome the compilation problems and its back in).

### v3.5.3
 * Original image, based on Debian Jessie

## Multi Architecture Support
Currently, this image should pull and run on the following architectures:
 * ```amd64```: Linux x86-64
 * ```arm32v7```, ```armv7l```: ARMv7 32-bit (Odroid HC1/HC2/XU4, RPi 2/3)
 * ```arm64v8```, ```aarch64```: ARMv8 64-bit (RPi 3B+/4)

## Prerequisites

Before this container will work properly, you must blacklist the kernel modules for the RTL-SDR USB device from the host's kernel.

To do this, create a file `/etc/modprobe.d/blacklist-rtl2832.conf` containing the following:

```
# Blacklist RTL2832 so docker container piaware can use the device

blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist rtl2832_sdr
```

Once this is done, you can plug in your RTL-SDR USB device and start the container.

Failure to do this will result in the error below being spammed to the container log.

```
2019-04-29 21:14:31.642500500  [dump1090-fa] Kernel driver is active, or device is claimed by second instance of librtlsdr.
2019-04-29 21:14:31.642635500  [dump1090-fa] In the first case, please either detach or blacklist the kernel module
2019-04-29 21:14:31.642663500  [dump1090-fa] (dvb_usb_rtl28xxu), or enable automatic detaching at compile time.
2019-04-29 21:14:31.642677500  [dump1090-fa]
2019-04-29 21:14:31.642690500  [dump1090-fa] usb_claim_interface error -6
```

If you get the error above even after blacklisting the kernel modules as outlined above, the modules may still be loaded. You can unload them by running the following commands:

```
sudo rmmod rtl2832_sdr
sudo rmmod dvb_usb_rtl28xxu
sudo rmmod rtl2832
```
## IMPORTANT!

* You need to specify a persistent MAC address for the container, as this is used by FlightAware to track your PiAware instance.
* With regards to your FlightAware Site ID:
  * Your site ID is housed in the path mapped to `/var/cache/piaware` in the container; OR
  * A site ID may be specified via the `FEEDER_ID` environment variable.
 
**Make sure you map `/var/cache/piaware` through to persistent storage OR set your feeder ID via the `FEEDER_ID` environment variable. Failure to do this will cause a new FlightAware site ID to be generated every time you launch the container.**

## Up-and-Running with `docker run`

Firstly, plug in your USB radio.

Run the command `lsusb` and find your radio. It'll look something like this:

```
Bus 001 Device 004: ID 0bda:2832 Realtek Semiconductor Corp. RTL2832U DVB-T
```

Take note of the bus number, and device number. In the output above, its 001 and 004 respectively.

Start the docker container, passing through the USB device:

```
docker run \
 -d \
 --rm \
 --mac-address xx:xx:xx:xx:xx:xx \
 --name piaware \
 --device /dev/bus/usb/USB_BUS_NUMBER/USB_DEVICE_NUMBER \
 -e TZ="YOUR_TIMEZONE" \
 -e LAT=LATITUDE_OF_YOUR_ANTENNA \
 -e LONG=LONGITUDE_OF_YOUR_ANTENNA \
 -p 8080:8080 \
 -v /path/to/piaware_cache:/var/cache/piaware \
 mikenye/piaware
```

For example, based on the `lsusb` output above:

```
docker run \
 -d \
 --rm \
 --mac-address de:ad:be:ef:13:37 \
 --name piaware \
 --device /dev/bus/usb/001/004 \
 -e TZ="Australia/Perth" \
 -e LAT=-30.657 \
 -e LONG=116.543 \
 -p 8080:8080 \
 -v /opt/piaware/piaware_cache:/var/cache/piaware \
 mikenye/piaware
```

## Up-and-Running with Docker Compose

Firstly, plug in your USB radio.

Run the command `lsusb` and find your radio. It'll look something like this:

```
Bus 001 Device 004: ID 0bda:2832 Realtek Semiconductor Corp. RTL2832U DVB-T
```

Take note of the bus number, and device number. In the output above, its 001 and 004 respectively. This is used in the `devices:` section of the `docker-compose.xml`. Change these in your environment as required.

An example `docker-compose.xml` file is below:

```
version: '2.0'

services:
  piaware:
    image: mikenye/piaware:latest
    tty: true
    container_name: piaware
    mac_address: de:ad:be:ef:13:37
    restart: always
    devices:
      - /dev/bus/usb/001/004:/dev/bus/usb/001/004
    ports:
      - 8080:8080
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-32.463873
      - LONG=113.458482
    volumes:
      - /var/cache/piaware:/var/cache/piaware
```



## Runtime Environment Variables

There are a series of available environment variables:

| Environment Variable | Purpose                         | Default |
| -------------------- | ------------------------------- | ------- |
| `LAT`                | Antenna's latitude (required)   |         |
| `LONG`               | Antenna's longitude (required)  |         |
| `TZ`                 | Your local timezone (optional)  | GMT     |
| `ALLOW_MLAT`         | Used for setting `piaware-config` variable `allow-mlat` (optional) | yes |
| `ALLOW_MODEAC`       | Used for setting `piaware-config` variable `allow-modead` (optional) | yes |
| `RTLSDR_PPM`         | Used for setting `piaware-config` variable `rtlsdr-ppm` (optional) | 0 |
| `RTLSDR_GAIN`        | Optimizing gain (optional) <br> See https://discussions.flightaware.com/t/thoughts-on-optimizing-gain/44482/2 | -10 <br> (max)|
| `BEASTHOST`          | Optional. IP/Hostname of a Mode-S/BEAST provider (dump1090/readsb). If given, no USB device needs to be passed through to the container. | |
| `BEASTPORT`          | Optional. TCP port number of Mode-S/BEAST provider (dump1090/readsb). | 30005 |

For an explanation of `piaware-config` variables, see https://flightaware.com/adsb/piaware/advanced_configuration.

## Ports

The following ports are used by this container:

* `8080` - dump1090 web interface (PiAware Skyview) - optional but recommended so you can look at the pretty maps and watch the planes fly around.
* `30001` - dump1090 TCP raw input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30002` - dump1090 TCP raw output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30003` - dump1090 TCP BaseStation output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30004` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30005` - dump1090 TCP Beast output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30104` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed

## Claiming

Since version 3.8.0 the `flightaware-user` and `flightaware-password` configuration options are no longer used; please use the normal site-claiming mechanisms to associate sites with a FlightAware account.

https://flightaware.com/adsb/piaware/claim

## Sending data to Flightradar24?

Check out the image `mikenye/fr24feed` which is designed to run in tandem with this image!

## Logging
* The `dump1090` and `piaware` processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.
* `dump1090` log file exists at `/var/log/dump1090/current`, with automatic log rotation (should grow no more than ~20MB)
* `piaware` log file exists at `/var/log/piaware/current`, with automatic log rotation (should grow no more than ~20MB)
* `lighttpd` is configured to not log (except for a startup message on container start)

## Note about dump978
I can get dump978 to compile in this docker image, however I don't have a suitable RTLSDR radio I can use to test this with. The FlightAware Pro Stick Plus Blue that I own has a 1090MHz bandpass filter built in, so it is basically useless for 978MHz. Furthermore, 978MHz is not yet used by aircraft in Australia. If anyone lives where 978MHz is used and wants to work on this project to include support for dump978, please get in touch! If you're interested in testing this yourself, see the master branch's unoptimised Dockerfile - the relevant lines are currently commented out. You can uncomment them and dump978 will build.
