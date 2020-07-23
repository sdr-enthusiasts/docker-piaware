#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Globals
S6_SERVICE_ROOT="/run/s6/services"
STR_HEALTHY="OK"
STR_UNHEALTHY="UNHEALTHY"

EXITCODE=0

function check_service_deathtally () {
    local service_name
    service_name=${1}

    # build service path
    local service_path
    service_path="${S6_SERVICE_ROOT%/}/${service_name}"

    # ensure service path exists
    if [[ -d "$service_path" ]]; then

        # get service death tally since last check
        local service_deathtally
        service_deathtally=$(s6-svdt "${service_path}" | wc -l)

        # clear death tally
        s6-svdt-clear "${service_path}"

        # print the first part of the text
        echo -n "\"${service_name}\" death tally since last check: ${service_deathtally}"

        # if healthy/unhealthy...
        if [[ "$service_deathtally" -gt 0 ]]; then
            echo ": $STR_UNHEALTHY"
            EXITCODE=1
        else
            echo ": $STR_HEALTHY"
        fi
    else

        # if service directory doesn't exist, throw an error
        echo "ERROR: service path \"$service_path\" does not exist!"
        EXITCODE=1
    fi
}

# MAIN

set -o pipefail

# check service death tallys
check_service_deathtally 'beastproxy'
check_service_deathtally 'beastrelay'
check_service_deathtally 'dump1090'
check_service_deathtally 'piaware'
check_service_deathtally 'skyaware'

# run piaware-status and store output
PIAWARE_STATUS=$(piaware-status)

# tests on piaware-status output
if [[ "$(echo "${PIAWARE_STATUS}" | grep -c "PiAware master process (piaware) is running")" -lt 1 ]]; then
    echo "piaware-status reports: PiAware master process (piaware) is NOT running: $STR_UNHEALTHY"
    EXITCODE=1
else
    echo "piaware-status reports: PiAware master process (piaware) is running: $STR_HEALTHY"
fi
if [[ "$(echo "${PIAWARE_STATUS}" | grep -c "dump1090 is NOT producing data on")" -gt 0 ]]; then
    echo "piaware-status reports: dump1090 is NOT producing data: $STR_UNHEALTHY"
    EXITCODE=1
else
    echo "piaware-status reports: dump1090 is producing data: $STR_HEALTHY"
fi
if [[ "$(echo "${PIAWARE_STATUS}" | grep -c "piaware is connected to FlightAware")" -lt 1 ]]; then
    echo "piaware is NOT conneceted to FlightAware: $STR_UNHEALTHY"
    EXITCODE=1
else
    echo "piaware is conneceted to FlightAware: $STR_HEALTHY"
fi

# ensure we're sending data to FA
DATETIME_NOW=$(date +%s)
# find last log entry reporting messages sent to FA
LOG_MSGS_SENT_LATEST=$(tail -100 /var/log/piaware/current | grep "msgs sent to FlightAware" | tail -1)
if [[ -z "$LOG_MSGS_SENT_LATEST" ]]; then
    echo "Logs indicate no msgs sent to FlightAware: $STR_UNHEALTHY"
    EXITCODE=1
fi
# get date of log entry
LOG_MSGS_SENT_LATEST_DATETIME=$(date --date="$(echo "$LOG_MSGS_SENT_LATEST" | grep -oP '^\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2}')" +%s)
if [[ -z "$LOG_MSGS_SENT_LATEST_DATETIME" ]]; then
    echo "Cannot determine date/time of last log entry of msgs sent to FlightAware: $STR_UNHEALTHY"
    EXITCODE=1
fi
# make sure last entry is less than 5 minutes old (plus extra minute grace period)
TIMEDELTA=$((DATETIME_NOW - LOG_MSGS_SENT_LATEST_DATETIME))
if [[ "$TIMEDELTA" -gt 360 ]]; then
    echo "Logs indicate no msgs sent to FlightAware in past 5 minutes: $STR_UNHEALTHY"
    EXITCODE=1
else
    # get number of messages in last 5 min
    LOG_MSGS_SENT_LATEST_NUM=$(echo "$LOG_MSGS_SENT_LATEST" | grep -oP '\(\d+ in last 5m\)' | cut -d '(' -f 2 | cut -d ' ' -f 1 | tr -d ' ')
    if [[ -z "$LOG_MSGS_SENT_LATEST_NUM" ]]; then
        echo "Cannot determine number of messages sent to FlightAware in last 5m: $STR_UNHEALTHY"
        EXITCODE=1
    else
        echo -n "Logs indicate $LOG_MSGS_SENT_LATEST_NUM msgs sent to FlightAware in past 5 minutes:"
        # make sure LOG_MSGS_SENT_LATEST_NUM is positive
        if [[ "$LOG_MSGS_SENT_LATEST_NUM" -lt 1 ]]; then
            echo " $STR_UNHEALTHY"
            EXITCODE=1
        else
            echo " $STR_HEALTHY"
        fi
    fi
fi

exit "$EXITCODE"
