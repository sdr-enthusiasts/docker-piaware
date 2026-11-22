#!/command/with-contenv bash
# shellcheck shell=bash

# Exit abnormally for any error
set -eo pipefail

# shellcheck disable=SC1091
source /scripts/healthcheck-common

# Set default exit code
EXITCODE=0

# Get list of flightaware server IPs
FA_SERVER_IPS=$(piaware-config -show adept-serverhosts | cut -d '{' -f 2 | cut -d '}' -f 1)

# Get flightaware server port
FA_SERVER_PORT=$(piaware-config -show adept-serverport)

# Define function to return number msgs sent to FA from a process for a given time
function check_logs_for_msgs_sent_to_fa () {
    # $1 = sending process (eg: dump1090, socat, dump978-fa)
    # $2 = number of minutes to consider (piaware logs one line per 5 minutes)
    # ------
    local intervals=$(($2 / 5))
    REGEX_FA_MSGS_SENT_PAST_5MIN="^\[+(?'date2'\d{4}-\d{1,2}-\d{1,2})\s+(?'time2'\d{1,2}:\d{1,2}:[\d\.]+)\]\[piaware\]\s+\d+ msgs recv'd from [^(]*$1[^(]*\(\K(?'msgslast5m'\d+) in last 5m\);\s+\d+ msgs sent to FlightAware\s*$"
    # piaware's first summary after it starts has no "(N in last 5m)" delta, only
    # the count so far. Later deltas don't include that count, so add up both.
    # Zero counts are skipped so restarts don't push older deltas out of the window.
    # No named groups here: they can't be repeated across the two alternatives.
    REGEX_FA_MSGS_SENT_FIRST_SUMMARY="^\[+\d{4}-\d{1,2}-\d{1,2}\s+\d{1,2}:\d{1,2}:[\d\.]+\]\[piaware\]\s+\K[1-9]\d*(?= msgs recv'd from [^(]*$1[^(]*;\s+\d+ msgs sent to FlightAware\s*$)"
    NUM_MSGS_RECEIVED=$(tail -$((intervals * 10)) /var/log/piaware/current | grep -oP "$REGEX_FA_MSGS_SENT_PAST_5MIN|$REGEX_FA_MSGS_SENT_FIRST_SUMMARY" | tail "-$intervals" | tr -s " " | cut -d " " -f 1)
    TOTAL_MSGS_RECEIVED=0
    for NUM_MSGS in $NUM_MSGS_RECEIVED; do
        TOTAL_MSGS_RECEIVED=$((TOTAL_MSGS_RECEIVED + NUM_MSGS))
    done
    echo "$TOTAL_MSGS_RECEIVED"
}

# A (re)started container may have lost its log, so assume data is flowing until
# it has been up for a whole window. Never for less than the 2 hour start period
# in the Dockerfile: Docker ends that period at the first successful check.
MIN_ASSUMED_OK_MINUTES=120
# Age of PID 1, as the wall clock can jump at boot on hosts without an RTC
UPTIME_MINUTES=$(awk -v hz="$(getconf CLK_TCK)" 'NR==FNR {up=$1; next} {sub(/.*\) /, ""); print int((up - $20 / hz) / 60)}' /proc/uptime /proc/1/stat || true)

# Define function to check whether it's too early to expect msgs sent to FA
function is_too_early_to_tell () {
    # $1 = number of minutes in the no-message window
    # ------
    local minutes=$(($1 > MIN_ASSUMED_OK_MINUTES ? $1 : MIN_ASSUMED_OK_MINUTES))
    # if the uptime is unknown, don't assume anything
    [[ "$UPTIME_MINUTES" =~ ^[0-9]+$ ]] && ((UPTIME_MINUTES < minutes))
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
    FA_DUMP1090_MSGS_SENT=$(check_logs_for_msgs_sent_to_fa dump1090 "$PIAWARE_NO_MSG_TIMEOUT_1090")
    if [[ "$FA_DUMP1090_MSGS_SENT" -gt 0 ]]; then
        echo "$FA_DUMP1090_MSGS_SENT dump1090 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_1090 minutes, OK."
    elif is_too_early_to_tell "$PIAWARE_NO_MSG_TIMEOUT_1090"; then
        echo "No dump1090 messages yet, container up for $UPTIME_MINUTES minutes, assuming OK."
    else
        echo "$FA_DUMP1090_MSGS_SENT dump1090 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_1090 minutes, NOT OK."
        EXITCODE=1
    fi
fi

# Make sure 978MHz data is being sent to flightaware
if [[ -n "$UAT_RECEIVER_HOST" ]]; then
    # look for log messages from UAT_RECEIVER_PORT
    FA_DUMP978_MSGS_SENT=$(check_logs_for_msgs_sent_to_fa "${UAT_RECEIVER_PORT:-30978}" "$PIAWARE_NO_MSG_TIMEOUT_978")
    if [[ "$FA_DUMP978_MSGS_SENT" -gt 0 ]]; then
        echo "$FA_DUMP978_MSGS_SENT dump978 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_978 minutes, OK."
    elif is_too_early_to_tell "$PIAWARE_NO_MSG_TIMEOUT_978"; then
        echo "No dump978 messages yet, container up for $UPTIME_MINUTES minutes, assuming OK."
    else
        echo "$FA_DUMP978_MSGS_SENT dump978 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_978 minutes, NOT OK."
        EXITCODE=1
    fi
elif [[ "$UAT_RECEIVER_TYPE" == "rtlsdr" ]]; then
    # look for log messages from dump978-fa
    FA_DUMP978_MSGS_SENT=$(check_logs_for_msgs_sent_to_fa dump978-fa "$PIAWARE_NO_MSG_TIMEOUT_978")
    if [[ "$FA_DUMP978_MSGS_SENT" -gt 0 ]]; then
        echo "$FA_DUMP978_MSGS_SENT dump978 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_978 minutes, OK."
    elif is_too_early_to_tell "$PIAWARE_NO_MSG_TIMEOUT_978"; then
        echo "No dump978 messages yet, container up for $UPTIME_MINUTES minutes, assuming OK."
    else
        echo "$FA_DUMP978_MSGS_SENT dump978 messages sent in past $PIAWARE_NO_MSG_TIMEOUT_978 minutes, NOT OK."
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
