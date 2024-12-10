#!/command/with-contenv bash
# shellcheck shell=bash

# Exit abnormally for any error
set -eo pipefail

# Set default exit code
EXITCODE=0

# Get list of flightaware server IPs
FA_SERVER_IPS=$(piaware-config -show adept-serverhosts | cut -d '{' -f 2 | cut -d '}' -f 1)

# Get flightaware server port
FA_SERVER_PORT=$(piaware-config -show adept-serverport)

# Define function to return number msgs sent to FA from a process for a given time
function check_logs_for_msgs_sent_to_fa () {
    # $1 = sending process (eg: dump1090, socat, dump978-fa)
    # $2 = number of output lines to consider (every line represents 5 minutes, so 12 would be an hour)
    # ------
    REGEX_FA_MSGS_SENT_PAST_5MIN="^\[+(?'date2'\d{4}-\d{1,2}-\d{1,2})\s+(?'time2'\d{1,2}:\d{1,2}:[\d\.]+)\]\[piaware\]\s+\d+ msgs recv'd from [^(]*$1[^(]*\(\K(?'msgslast5m'\d+) in last 5m\);\s+\d+ msgs sent to FlightAware\s*$"
    NUM_MSGS_RECEIVED=$(tail -$(($2 * 10)) /var/log/piaware/current | grep -oP "$REGEX_FA_MSGS_SENT_PAST_5MIN" | tail "-$2" | tr -s " " | cut -d " " -f 1)
    TOTAL_MSGS_RECEIVED=0
    for NUM_MSGS in $NUM_MSGS_RECEIVED; do
        TOTAL_MSGS_RECEIVED=$((TOTAL_MSGS_RECEIVED + NUM_MSGS))
    done
    echo "$TOTAL_MSGS_RECEIVED"
}

# Make sure there is an established connection to flightaware
CONNECTED_TO_FA=""
for FA_SERVER_IP in $FA_SERVER_IPS; do
    SS_LINES=$(ss -Hnt state established dport "$FA_SERVER_PORT" dst "$FA_SERVER_IP" | wc -l)
    if [ "$SS_LINES" -ge 1 ]; then
        CONNECTED_TO_FA="true"
        break 2
    fi
done
# if previous section didn't find a connection to FA, lets try something else
if [[ -z "$CONNECTED_TO_FA" ]]; then
    SS_LINES=$(ss -Hnt state established dport "$FA_SERVER_PORT" | wc -l)
    if [ "$SS_LINES" -ge 1 ]; then
        CONNECTED_TO_FA="true"
    fi
fi
if [[ -z "$CONNECTED_TO_FA" ]]; then
    echo "No connection to Flightaware, NOT OK."
    EXITCODE=1
else
    echo "Connected to Flightaware, OK."
fi

# Make sure 1090MHz data is being sent to flightaware
if [[ -n "$BEASTHOST" || "$RECEIVER_TYPE" == "rtlsdr" ]]; then
    # look for log messages from dump1090
    FA_DUMP1090_MSGS_SENT_PAST_HOUR=$(check_logs_for_msgs_sent_to_fa dump1090 12)
    if [[ "$FA_DUMP1090_MSGS_SENT_PAST_HOUR" -gt 0 ]]; then
        echo "$FA_DUMP1090_MSGS_SENT_PAST_HOUR dump1090 messages sent in past hour, OK."
    else
        echo "$FA_DUMP1090_MSGS_SENT_PAST_HOUR dump1090 messages sent in past hour, NOT OK."
        EXITCODE=1
    fi
fi

# Make sure 978MHz data is being sent to flightaware
if [[ -n "$UAT_RECEIVER_HOST" ]]; then
    # look for log messages from UAT_RECEIVER_PORT
    FA_DUMP978_MSGS_SENT_PAST_HOUR=$(check_logs_for_msgs_sent_to_fa $UAT_RECEIVER_PORT 24)
    if [[ "$FA_DUMP978_MSGS_SENT_PAST_HOUR" -gt 0 ]]; then
        echo "$FA_DUMP978_MSGS_SENT_PAST_HOUR dump978 messages sent in past 2 hours, OK."
    else
        echo "$FA_DUMP978_MSGS_SENT_PAST_HOUR dump978 messages sent in past 2 hours, NOT OK."
        EXITCODE=1
    fi
elif [[ "$UAT_RECEIVER_TYPE" == "rtlsdr" ]]; then
    # look for log messages from dump978-fa
    FA_DUMP1090_MSGS_SENT_PAST_HOUR=$(check_logs_for_msgs_sent_to_fa dump978-fa 24)
    if [[ "$FA_DUMP978_MSGS_SENT_PAST_HOUR" -gt 0 ]]; then
        echo "$FA_DUMP978_MSGS_SENT_PAST_HOUR dump978 messages sent in past 2 hours, OK."
    else
        echo "$FA_DUMP978_MSGS_SENT_PAST_HOUR dump978 messages sent in past 2 hours, NOT OK."
        EXITCODE=1
    fi
fi

# Make sure web server listening on port 80
if [ "$(ss -Hltn sport 80 | wc -l)" -ge 1 ]; then
    echo "Webserver listening on port 80, OK."
else
    echo "Webserver not listening on port 80, NOT OK."
    EXITCODE=1
fi

# Make sure web server listening on port 8080
if [ "$(ss -Hltn sport 8080 | wc -l)" -ge 1 ]; then
    echo "Webserver listening on port 8080, OK."
else
    echo "Webserver not listening on port 8080, NOT OK."
    EXITCODE=1
fi

# Exit with determined exit status
exit "$EXITCODE"
