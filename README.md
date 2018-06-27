# docker-piaware
PiAware docker container including support for bladeRF, RTLSDR. Includes dump1090-fa.

Has the ability to run as privileged mode (for quick and easy), or non-privileged mode (not as quick and easy, but more secure).

Tested and working on:
 * x86 platform running Ubuntu 16.04.4 LTS using an RTL2832U radio (FlightAware Pro Stick Plus Blue)
 * if you get it running on a different platform (or if you have issues) please raise an issue

## Multi Architecture Support
Currently, this image should pull and run on the following architectures:
 * ```arm64```: Linux x86-64
 * ```arm32v7```, ```armv7l```: ARMv7 32-bit (Odroid HC1/HC2/XU4, RPi 2/3)
 
ARM support is not as thoroughly tested as x86-64. If you run on ARM, please let me know your results by raising an issue over on the GitHub repository https://github.com/mikenye/docker-piaware by raising an issue!

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

* `TZ` - Your local timezone
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


## Notes

* You need to specify a persistent MAC address for the container, as this is used by FlightAware to track your PiAware instance.
* Your site ID is housed in the path mapped to `/var/cache/piaware` in the container. Make sure you map this through to persistent storage or you'll create a new FlightAware site ID every time you launch the container.
* dump1090's stats can be viewed with "docker logs <container>".
* piaware's log can be viewed with "docker exec -it <container> tail -F /var/log/piaware"
