#!/usr/bin/env python3

import os
import sys
import subprocess

def check_service_deathcount(service_name, service_path):

    HEALTHY = True
    
    # check death count for service
    proc = subprocess.run(
        ["s6-svdt", service_path], 
        stderr=subprocess.PIPE, 
        stdout=subprocess.PIPE,
        )
    deathcount = 0
    for x in proc.stdout.decode('UTF-8').split('\n'):
        if x.count('exitcode') > 0:
            deathcount += 1
    if deathcount > 0:
        HEALTHY = False
        print("Death count of '%s' service since last check: %s - unhealthy" % (service_name, deathcount))
    else:
        print("Death count of '%s' service since last check: %s - healthy" % (service_name, deathcount))
    
    # reset death count for service
    proc = subprocess.run(
        ["s6-svdt-clear", service_path], 
        stderr=subprocess.PIPE, 
        stdout=subprocess.PIPE,
        )

    return HEALTHY

def check_piaware_status():

    HEALTHY = True

    # run 'piaware-status' and capture output
    proc = subprocess.run(
        ["piaware-status",], 
        stderr=subprocess.PIPE, 
        stdout=subprocess.PIPE,
        )

    # look for telltale signs of a problem
    for x in proc.stdout.decode('UTF-8').split('\n'):
        if x.count('dump1090 is NOT producing data on') > 0:
            HEALTHY = False
            print("piaware-status reports: dump1090 is NOT producing data - unhealthy")

    if HEALTHY:
        print("piaware-status - healthy")

    return HEALTHY

if __name__ == "__main__":

    all_health_checks = list()

    all_health_checks.append(check_service_deathcount("beastproxy", "/run/s6/services/beastproxy"))
    all_health_checks.append(check_service_deathcount("beastrelay", "/run/s6/services/beastrelay"))
    all_health_checks.append(check_service_deathcount("dump1090", "/run/s6/services/dump1090"))
    all_health_checks.append(check_service_deathcount("piaware", "/run/s6/services/piaware"))
    all_health_checks.append(check_service_deathcount("skyaware", "/run/s6/services/skyaware"))
    all_health_checks.append(check_piaware_status())
    
    if False in all_health_checks:
        print("Container is UNHEALTHY :-(")
        sys.exit(1)
    else:
        print("Container is HEALTHY :-)")
        sys.exit(0)
