#!/bin/sh
awk "$(cat /run/dump1090*/stats.json| grep total | sed 's/.*accepted":\[\([0-9]*\).*strong_signals":\([0-9]*\).*/BEGIN {printf "\\nPercentage of strong messages: %.3f \\n" , \2 * 100 \/ \1}/')"

