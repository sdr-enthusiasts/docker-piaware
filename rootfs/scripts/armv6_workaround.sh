#!/usr/bin/env bash

# Usage /path/to/armv6_workaround.sh Makefile

# Determine architecture
FILEBINARY=$(which file)
FILEOUTPUT=$("${FILEBINARY}" -L "${FILEBINARY}")
if echo "${FILEOUTPUT}" | grep "Intel 80386" > /dev/null; then TARGET_ARCH="x86"; fi
if echo "${FILEOUTPUT}" | grep "x86-64" > /dev/null; then TARGET_ARCH="amd64"; fi
if echo "${FILEOUTPUT}" | grep "ARM" > /dev/null; then TARGET_ARCH="arm"; fi
if echo "${FILEOUTPUT}" | grep "armhf" > /dev/null; then TARGET_ARCH="armhf"; fi
if echo "${FILEOUTPUT}" | grep "aarch64" > /dev/null; then TARGET_ARCH="aarch64"; fi
if [ -z "${TARGET_ARCH}" ]; then exit 1; fi

# Workaround for compiling for armv6
# shellcheck disable=SC2016
if [[ "$TARGET_ARCH" == "arm" ]]; then sed -i 's/ARCH ?= $(shell uname -m)/ARCH ?= generic/g' "$1"; fi
