#!/bin/bash
#

ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

/usr/bin/dump1090-fa --net --gain -10 --ppm 1 --lat ${LAT} --lon ${LONG} --max-range 400 \
                     --net-ro-size 500 --net-ro-interval 1 --net-buffer 2 --mlat --fix \
                     --stats-every 3600 --quiet --write-json /run/dump1090-fa --json-location-accuracy 2 &
     
echo "Adding user $USERNAME and password $PASSWORD to Flightaware configuration"
echo user $USERNAME >> /root/.piaware
echo password $PASSWORD >> /root/.piaware

service lighttpd stop
service lighttpd start
service lighttpd status

/usr/bin/piaware -v
/usr/bin/piaware -statusfile /run/piaware/status.json
