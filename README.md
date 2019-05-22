# docker-piaware
FlightAware's PiAware docker container including support for bladeRF, RTLSDR. Includes dump1090-fa (but not yet dump978, see endnote). Builds and runs on x86_64 and ARMv7 (see below).

For more information on what PiAware is, see here: https://flightaware.com/adsb/piaware/

Has the ability to run as privileged mode (for quick and easy), or non-privileged mode (not as quick and easy, but more secure).

Tested and working on:
 * `x86_64` (`amd64`) platform running Ubuntu 16.04.4 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * `armv7l` platform (Odroid HC1) running Ubuntu 18.04.1 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * If you run on a different platform (or if you have issues) please raise an issue and let me know!
 * bladeRF is untested - I don't own bladeRF hardware, but support for the devices is compiled in. If you have bladeRF and this container works for you, please let me know!

## Supported tags and respective Dockerfiles
* `latest`, `3.7.1`
  * `latest-amd64`, `3.7.1-amd64` (`3.7.1` branch, `Dockerfile.amd64`)
  * `latest-arm32v7`, `3.7.1-arm32v7` (`3.7.1` branch, `Dockerfile.armv7l`)
* `3.6.3`
  * `3.6.3-amd64` (`3.6.3` branch, `Dockerfile.amd64`)
  * `3.6.3-arm32v7` (`3.6.3` branch, `Dockerfile.armv7l`)
* `3.5.3`
  * `3.5.3-amd64` (`3.5.3` branch, `Dockerfile`)
  * `3.5.3-arm32v7` (`3.5.3` branch, `Dockerfile`)
* `development` (`master` branch, `Dockerfile`, `amd64` architecture only, not recommended for production)

## Changelog

### v3.7.1
 * Update piaware to v3.7.1

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
* Your site ID is housed in the path mapped to `/var/cache/piaware` in the container. **Make sure you map this through to persistent storage or you'll create a new FlightAware site ID every time you launch the container.**

## Up-and-Running - Non-Privileged Mode

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
 -e USERNAME="YOUR_FLIGHTAWARE_USERNAME" \
 -e PASSWORD="YOUR_FLIGHTAWARE_PASSWORD" \
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
 -e USERNAME="pointyfergusson" \
 -e PASSWORD="password1234" \
 -e LAT=-30.657 \
 -e LONG=116.543 \
 -p 8080:8080 \
 -v /opt/piaware/piaware_cache:/var/cache/piaware \
 mikenye/piaware
```

## Up-and-Running - Privileged Mode

Firstly, plug in your USB radio.

Start the docker container:

```
docker run \
 -d \
 --rm \
 --mac-address xx:xx:xx:xx:xx:xx \
 --name piaware \
 --privileged
 -e TZ="YOUR_TIMEZONE" \
 -e USERNAME="YOUR_FLIGHTAWARE_USERNAME" \
 -e PASSWORD="YOUR_FLIGHTAWARE_PASSWORD" \
 -e LAT=LATITUDE_OF_YOUR_ANTENNA \
 -e LONG=LONGITUDE_OF_YOUR_ANTENNA \
 -p 8080:8080 \
 -v /path/to/piaware_cache:/var/cache/piaware \
 mikenye/piaware
```

For example:

```
docker run \
 -d \
 --rm \
 --mac-address de:ad:be:ef:13:37 \
 --name piaware \
 --privileged
 -e TZ="Australia/Perth" \
 -e USERNAME="pointyfergusson" \
 -e PASSWORD="password1234" \
 -e LAT=-30.657 \
 -e LONG=116.543 \
 -p 8080:8080 \
 -v /opt/piaware/piaware_cache:/var/cache/piaware \
 mikenye/piaware
```

## Runtime Configuration Options

There are a series of available variables you are required to set:

* `TZ` - Your local timezone (optional)
* `USERNAME` - FlightAware account username
* `PASSWORD` - FlightAware account password
* `LAT` - Antenna's latitude
* `LONG` - Antenna's longitude


## Ports

The following ports are used by this container:

* `8080` - dump1090 web interface (PiAware Skyview) - optional but recommended so you can look at the pretty maps and watch the planes fly around.
* `30001` - dump1090 TCP raw input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30002` - dump1090 TCP raw output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30003` - dump1090 TCP BaseStation output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30004` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed
* `30005` - dump1090 TCP Beast output listen port - optional, recommended to leave unmapped unless explicitly needed
* `30104` - dump1090 TCP Beast input listen port - optional, recommended to leave unmapped unless explicitly needed


## Logging
* The `dump1090` and `piaware` processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.
* `dump1090` log file exists at `/var/log/dump1090/current`, with automatic log rotation (should grow no more than ~20MB)
* `piaware` log file exists at `/var/log/piaware/current`, with automatic log rotation (should grow no more than ~20MB)
* `lighttpd` is configured to not log (except for a startup message on container start)

## Note about dump978
I can get dump978 to compile in this docker image, however I don't have a suitable RTLSDR radio I can use to test this with. The FlightAware Pro Stick Plus Blue that I own has a 1090MHz bandpass filter built in, so it is basically useless for 978MHz. If someone wants to send me a radio to test with, please get in touch! If you're interested in testing this yourself, see the master branch's unoptimised Dockerfile - the relevant lines are currently commented out. You can uncomment them and dump978 will build.

In future if this image is to support both dump1090 and dump978, I'll need to implement a way for the user to specify which radios are to be used for each. Likely a shell script that runs on container start, that determines which radio to use based on serial numbers passed in via environment variables...

