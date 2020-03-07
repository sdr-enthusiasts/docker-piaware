# mikenye/piaware
FlightAware's PiAware docker container including support for bladeRF, RTLSDR. Includes dump1090-fa (but not yet dump978, see endnote). Builds and runs on `linux/amd64`, `linux/arm/v7` and `linux/arm64` (see below).

Can optionally pull Mode-S/BEAST data from another host/container running `readsb`/`dump1090`.

For more information on what PiAware is, see here: https://flightaware.com/adsb/piaware/

Tested and working on:
 * `linux/amd64` (`x86_64`) platform running Ubuntu 16.04.4 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * `linux/arm/v7` (`armv7l`, `armhf`, `arm32v7`) platform (Odroid HC1) running Ubuntu 18.04.1 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * `linux/arm64` (`aarch64`, `arm64v8`) platform (Raspberry Pi 4) running Raspbian Buster 64-bit using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * If you run on a different platform (or if you have issues) please raise an issue and let me know!
 * bladeRF is untested - I don't own bladeRF hardware, but support for the devices is compiled in. If you have bladeRF and this container works for you, please let me know!

## Supported tags and respective Dockerfiles
* `latest`, [`3.8.0_2`](https://hub.docker.com/layers/mikenye/piaware/3.8.0_2/images/sha256-01b68b80057fdac1d650b50223487ff203e23ab792f52740013430e8b2b42e95?context=repo) ([`3.8.0_2` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0_2), [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/3.8.0_2/Dockerfile))
* [`3.8.0_1`](https://hub.docker.com/layers/mikenye/piaware/3.8.0_1/images/sha256-7bb8c44b1b49594774c7670ce6d16b5079f9d9d12fc9fceb81519ac8ba822b42?context=repo)
  * [`3.8.0_1-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.8.0_1-amd64/images/sha256-c39282f8be04b3effe1c8c2884f68566f2f30ba8b52c7a6ff2d7720c182815cc?context=repo) ([`3.8.0_1` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0_1), [`Dockerfile.amd64`](https://github.com/mikenye/docker-piaware/blob/3.8.0_1/Dockerfile.amd64))
  * [`3.8.0_1-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.8.0_1-arm32v7/images/sha256-a43dfc1b4239cd3e50ccf85c1df3e1e8a15b5d1ad7d52405e6f3eef739d942b5?context=repo) ([`3.8.0_1` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0_1), [`Dockerfile.arm32v7`](https://github.com/mikenye/docker-piaware/blob/3.8.0_1/Dockerfile.arm32v7))
  * [`3.8.0_1-arm64v8`](https://hub.docker.com/layers/mikenye/piaware/3.8.0_1-arm64v8/images/sha256-7bb8c44b1b49594774c7670ce6d16b5079f9d9d12fc9fceb81519ac8ba822b42?context=repo) ([`3.8.0_1` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0_1), [`Dockerfile.arm64v8`](https://github.com/mikenye/docker-piaware/blob/3.8.0_1/Dockerfile.arm64v8))
* [`3.8.0`](https://hub.docker.com/layers/mikenye/piaware/3.8.0/images/sha256-dc3f0fad33c142b70456baf148589d25915572e05aa5876071f8456e932e31a3?context=repo)
  * [`3.8.0-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.8.0-amd64/images/sha256-e76164988dacbf7d18782e72d450bf21e3469c6b8c2cfe8f3b0506974e713461?context=repo) ([`3.8.0` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0), [`Dockerfile.amd64`](https://github.com/mikenye/docker-piaware/blob/3.8.0/Dockerfile.amd64))
  * [`3.8.0-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.8.0-arm32v7/images/sha256-3e361dd39d1024f357fe9f252bd45949c6d68e0f6ec497d37ba2e9989c70f330?context=repo) ([`3.8.0` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0), [`Dockerfile.arm32v7`](https://github.com/mikenye/docker-piaware/blob/3.8.0/Dockerfile.arm32v7))
  * [`3.8.0-arm64v8`](https://hub.docker.com/layers/mikenye/piaware/3.8.0-arm64v8/images/sha256-dc3f0fad33c142b70456baf148589d25915572e05aa5876071f8456e932e31a3?context=repo) ([`3.8.0` branch](https://github.com/mikenye/docker-piaware/tree/3.8.0), [`Dockerfile.arm64v8`](https://github.com/mikenye/docker-piaware/blob/3.8.0/Dockerfile.arm64v8))
* [`3.7.2`](https://hub.docker.com/layers/mikenye/piaware/3.7.2/images/sha256-c3547060d0962450ab3596482432a8b383203fb5734ab947e1c3c89913d69491?context=repo)
  * [`3.7.2-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.7.2-amd64/images/sha256-8226a9ea332677c646f27be9a04e72d81e920477158e010139c86d12995530f5?context=repo) ([`3.7.2` branch](https://github.com/mikenye/docker-piaware/tree/3.7.2), [`Dockerfile.amd64`](https://github.com/mikenye/docker-piaware/blob/3.7.2/Dockerfile.amd64))
  * [`3.7.2-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.7.2-arm32v7/images/sha256-c3547060d0962450ab3596482432a8b383203fb5734ab947e1c3c89913d69491?context=repo) ([`3.7.2` branch](https://github.com/mikenye/docker-piaware/tree/3.7.2), [`Dockerfile.arm32v7`](https://github.com/mikenye/docker-piaware/blob/3.7.2/Dockerfile.arm32v7))
  * [`3.7.2-arm64v8`](https://hub.docker.com/layers/mikenye/piaware/3.7.2-arm64v8/images/sha256-bac1329c41878b67c2200be14ce47654b13f05d6ca92b2b9c1172f568a6e29b1?context=repo) ([`3.7.2` branch](https://github.com/mikenye/docker-piaware/tree/3.7.2), [`Dockerfile.arm64v8`](https://github.com/mikenye/docker-piaware/blob/3.7.2/Dockerfile.arm64v8))
* [`3.7.1`](https://hub.docker.com/layers/mikenye/piaware/3.7.1/images/sha256-fc121cc3747766c61defe821eaab1ce6ebdf1afddb4b120f198c53875952baca?context=repo)
  * [`3.7.1-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.7.1-amd64/images/sha256-964e36e6a616fa7e83d5157149f04e397dc19d59f82dacb76abb71612bb017a8?context=repo) ([`3.7.1` branch](https://github.com/mikenye/docker-piaware/tree/3.7.1), [`Dockerfile.amd64`](https://github.com/mikenye/docker-piaware/blob/3.7.1/Dockerfile.amd64))
  * [`3.7.1-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.7.1-arm32v7/images/sha256-fc121cc3747766c61defe821eaab1ce6ebdf1afddb4b120f198c53875952baca?context=repo) ([`3.7.1` branch](https://github.com/mikenye/docker-piaware/tree/3.7.1), [`Dockerfile.armv7l`](https://github.com/mikenye/docker-piaware/blob/3.7.1/Dockerfile.armv7l))
  * [`3.7.1-arm64v8`](https://hub.docker.com/layers/mikenye/piaware/3.7.1-arm64v8/images/sha256-c99d175e27e6908e735832777631b3c0b523e6595b4e26797c1c61311765802e?context=repo) ([`3.7.1` branch](https://github.com/mikenye/docker-piaware/tree/3.7.1), [`Dockerfile.aarch64`](https://github.com/mikenye/docker-piaware/blob/3.7.1/Dockerfile.aarch64))
* [`3.6.3`](https://hub.docker.com/layers/mikenye/piaware/3.6.3/images/sha256-e2f68f95237d6aa465c5f34beaee40fbe518d456e6563cd8b770605311d6c0d3?context=repo)
  * [`3.6.3-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.6.3-amd64/images/sha256-e2f68f95237d6aa465c5f34beaee40fbe518d456e6563cd8b770605311d6c0d3?context=repo) ([`3.6.3` branch](https://github.com/mikenye/docker-piaware/tree/3.6.3), [`Dockerfile.amd64`](https://github.com/mikenye/docker-piaware/blob/3.6.3/Dockerfile.amd64))
  * [`3.6.3-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.6.3-arm32v7/images/sha256-efcfc443e5d38ef40b67208113760b646ae4022f4e40dec52bdb384bbb37df51?context=repo) ([`3.6.3` branch](https://github.com/mikenye/docker-piaware/tree/3.6.3), [`Dockerfile.armv7l`](https://github.com/mikenye/docker-piaware/blob/3.6.3/Dockerfile.armv7l))
* [`3.5.3`](https://hub.docker.com/layers/mikenye/piaware/3.5.3/images/sha256-0e100a74e7fc0f68cad50cfb8f06d50ac39788bf0f71a9c1c5da40eb57abdf1b?context=repo)
  * [`3.5.3-amd64`](https://hub.docker.com/layers/mikenye/piaware/3.5.3-amd64/images/sha256-828ab34110d21458e4e24992506b20de5e9f820968f03ac681c230802cd213c3?context=repo) ([`3.5.3` branch](https://github.com/mikenye/docker-piaware/tree/3.5.3), [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/3.5.3/Dockerfile))
  * [`3.5.3-arm32v7`](https://hub.docker.com/layers/mikenye/piaware/3.5.3-arm32v7/images/sha256-0e100a74e7fc0f68cad50cfb8f06d50ac39788bf0f71a9c1c5da40eb57abdf1b?context=repo) ([`3.5.3` branch](https://github.com/mikenye/docker-piaware/tree/3.5.3), [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/3.5.3/Dockerfile))
* `development` ([`master` branch](https://github.com/mikenye/docker-piaware/tree/master), [`Dockerfile`](https://github.com/mikenye/docker-piaware/blob/master/Dockerfile), `amd64` architecture only, not recommended for production)

## Contributors
 * Thanks to [Jan Collijs](https://github.com/visibilityspots) for contributing to the 3.7.1, 3.7.2 and 3.8.0 releases.

## Changelog

### v3.8.0_2
 * Update Alpine Linux image to 3.11
 * Update bladeRF version to 2019.07
 * Change to single, multi-architecture `Dockerfile`
 * Change to `docker buildx` for release building
 * Use [mikenye/deploy-s6-overlay](https://github.com/mikenye/deploy-s6-overlay) to deploy s6-overlay

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
 * `linux/amd64` (`x86_64`): Built on Linux x86-64
 * `linux/arm/v7` (`armv7l`, `armhf`, `arm32v7`): Built on Odroid HC2 running ARMv7 32-bit
 * `linux/arm64` (`aarch64`, `arm64v8`): Built on a Raspberry Pi 4 Model B running ARMv8 64-bit

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

* You need to specify a feeder-id for the container, as this is used by FlightAware to track your PiAware instance.
 
**Make sure you set your feeder ID via the `FEEDER_ID` environment variable. Failure to do this will cause a new FlightAware site ID to be generated every time you launch the container.**

See below for more info.

## Already running PiAware?

You'll need your *feeder-id* from your existing feeder.

To get your *feeder-id*, log onto your feeder and issue the command:

```
piaware-config -show feeder-id
```

## New to PiAware?

You'll need a *feeder-id*. To get one, you can temporarily run the container, to allow it to communicate with the FlightAware servers and get a new feeder ID.

Run the command:

```
timeout 30 docker run --rm -e LAT=YOURLATITUDE -e LONG=YOURLONGITUDE mikenye/piaware:latest | grep "my feeder ID"
```

Be sure to change the following:
* Replace `YOURLATITUDE` with the latitude of your antenna (xx.xxxxx)
* Replace `YOURLONGITUDE` with the longitude of your antenna (xx.xxxxx)

The command will run the container for 30 seconds, which should be ample time for the container to receive a feeder-id.

For example:

```
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

To do this, go to: https://flightaware.com/adsb/piaware/claim and follow the instructions there.

## Up-and-Running with `docker run` with RTLSDR USB

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
 --name piaware \
 --device /dev/bus/usb/USB_BUS_NUMBER/USB_DEVICE_NUMBER \
 -e TZ="YOUR_TIMEZONE" \
 -e LAT=LATITUDE_OF_YOUR_ANTENNA \
 -e LONG=LONGITUDE_OF_YOUR_ANTENNA \
 -p 8080:8080 \
 mikenye/piaware
```

For example, based on the `lsusb` output above:

```
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb/001/004 \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -p 8080:8080 \
 mikenye/piaware
```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then re-create your container:

```
docker run \
 -d \
 --rm \
 --name piaware \
 --device /dev/bus/usb/001/004 \
 -e TZ="Australia/Perth" \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e FEEDER_ID=c478b1c99-23d3-4376-1f82-47352a28cg37 \
 -p 8080:8080 \
 mikenye/piaware
```

## Up-and-Running with Docker Compose with RTLSDR USB

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
    restart: always
    devices:
      - /dev/bus/usb/001/004:/dev/bus/usb/001/004
    ports:
      - 8080:8080
      - 30003:30003
      - 30005:30005
    environment:
      - TZ="Australia/Perth"
      - LAT=-33.33333
      - LONG=111.11111
    
```

After running for the first time, it is strongly suggested to get your feeded ID from the container logs, and re-create the container with the `FEEDER_ID` environment variable set.

For example:

```
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then update your `docker-compose.yml` file:

```
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
      - 8080:8080
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

```
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

```
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

```
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then re-create your container:

```
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

```
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

```
docker logs piaware | grep -i 'my feeder id'
```

...should return something like:

```
2020-02-19 16:17:03.153071500 [piaware] my feeder ID is c478b1c99-23d3-4376-1f82-47352a28cg37
```

You would then update your `docker-compose.yml` file:

```
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
| `ALLOW_MLAT`         | Used for setting `piaware-config` variable `allow-mlat` (optional) | yes |
| `ALLOW_MODEAC`       | Used for setting `piaware-config` variable `allow-modead` (optional) | yes |
| `RTLSDR_PPM`         | Used for setting `piaware-config` variable `rtlsdr-ppm` (optional) | 0 |
| `RTLSDR_GAIN`        | Optimizing gain (optional) <br> See https://discussions.flightaware.com/t/thoughts-on-optimizing-gain/44482/2 | -10 <br> (max)|
| `BEASTHOST`          | Optional. IP/Hostname of a Mode-S/BEAST provider (dump1090/readsb). If given, no USB device needs to be passed through to the container. | |
| `BEASTPORT`          | Optional. TCP port number of Mode-S/BEAST provider (dump1090/readsb). | 30005 |
| `FEEDER_ID`          | Your FlightAware feeder ID (required) | |

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

## Feed to other services!

Check out the images:
* [mikenye/adsbexchange](https://hub.docker.com/r/mikenye/adsbexchange)
* [mikenye/fr24feed](https://hub.docker.com/r/mikenye/fr24feed)
* [mikenye/docker-readsb](https://github.com/mikenye/docker-readsb)

## Logging
* The `dump1090` and `piaware` processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.
* `dump1090` log file exists at `/var/log/dump1090/current`, with automatic log rotation (should grow no more than ~20MB)
* `piaware` log file exists at `/var/log/piaware/current`, with automatic log rotation (should grow no more than ~20MB)
* `lighttpd` is configured to not log (except for a startup message on container start)

## Note about dump978
I can get dump978 to compile in this docker image, however I don't have a suitable RTLSDR radio I can use to test this with. The FlightAware Pro Stick Plus Blue that I own has a 1090MHz bandpass filter built in, so it is basically useless for 978MHz. Furthermore, 978MHz is not yet used by aircraft in Australia. If anyone lives where 978MHz is used and wants to work on this project to include support for dump978, please get in touch! If you're interested in testing this yourself, see the master branch's unoptimised Dockerfile - the relevant lines are currently commented out. You can uncomment them and dump978 will build.

## Getting help
Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-piaware/issues).
