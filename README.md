# docker-piaware
FlightAware's PiAware docker container including support for ~bladeRF,~ RTLSDR. Includes dump1090-fa. Builds and runs on x86_64 and ARMv7 (see below).

For more information on what PiAware is, see here: https://flightaware.com/adsb/piaware/

Has the ability to run as privileged mode (for quick and easy), or non-privileged mode (not as quick and easy, but more secure).

Tested and working on:
 * x86_64 (amd64) platform running Ubuntu 16.04.4 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * armv7l platform (Odroid HC1) running Ubuntu 18.04.1 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * if you get it running on a different platform (or if you have issues) please raise an issue

## Changelog

### v3.6.3
 * Update piaware to v3.6.3
 * Reduction of image size 663MB down to 304MB
    * Change base image to Alpine v3.9
    * Reduce build layers
    * The "unoptimised" version of the Dockerfile is available in the source repo for educational/troubleshooting purposes
 * Implement s6-overlay for process supervision
 * Make logging much better
 * **Drop support for bladeRF** (for now as I can't get it to compile properly, **if you use bladeRF stay on version 3.5.3 for now**)

### v3.5.3
 * Original image (including bladeRF support)

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
 --device /dev/bus/usb/<usb_bus_number>/<usb_device_number> \
 -e TZ="<your_timezone>" \
 -e USERNAME="<your_flightaware_username>" \
 -e PASSWORD="<your_flightaware_password>" \
 -e LAT=<latitude_of_your_antenna> \
 -e LONG=<longitude_of_your_antenna> \
 -p 8080:8080 \
 -v </path/to/piaware_cache>:/var/cache/piaware \
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
 -e TZ="<your_timezone>" \
 -e USERNAME="<your_flightaware_username>" \
 -e PASSWORD="<your_flightaware_password>" \
 -e LAT=<latitude_of_your_antenna> \
 -e LONG=<longitude_of_your_antenna> \
 -p 8080:8080 \
 -v </path/to/piaware_cache>:/var/cache/piaware \
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


## IMPORTANT!

* You need to specify a persistent MAC address for the container, as this is used by FlightAware to track your PiAware instance.
* Your site ID is housed in the path mapped to `/var/cache/piaware` in the container. Make sure you map this through to persistent storage or you'll create a new FlightAware site ID every time you launch the container.
