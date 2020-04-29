FROM alpine:3.11
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    DUMP1090_MAX_RANGE=400 \
    ALLOW_MODEAC=yes \
    ALLOW_MLAT=yes \
    RTLSDR_GAIN=-10 \
    RTLSDR_PPM=0 \
    BEASTPORT=30005 \
    BRANCH_RTLSDR="d794155ba65796a76cd0a436f9709f4601509320"

# Note, the specific commit of rtlsdr is to address issue #15
# See: https://github.com/mikenye/docker-piaware/issues/15
# This should be revisited in future when rtlsdr 0.6.1 or newer is released

RUN set -x && \
    apk update && \
    apk add \
    autoconf \
    bash \
    boost-dev \
    cmake \
    g++ \
    gcc \
    git \
    gnupg \
    libusb-dev \
    lighttpd \
    make \
    musl-dev \
    ncurses-dev \
    net-tools \
    py3-numpy \
    python3 \
    python3-dev \
    socat \
    swig \
    tcl \
    tcl-dev \
    tcl-tls \
    tclx \
    tzdata \
    && \
    git config --global advice.detachedHead false && \
    mkdir -p /src && \
    mkdir -p /var/cache/lighttpd/compress && \
    chown lighttpd:lighttpd /var/cache/lighttpd/compress && \
    echo "========== Install RTL-SDR ==========" && \
    git clone git://git.osmocom.org/rtl-sdr.git /src/rtl-sdr && \
    cd /src/rtl-sdr && \
    #export BRANCH_RTLSDR=$(git tag --sort="-creatordate" | head -1) && \
    #git checkout tags/${BRANCH_RTLSDR} && \
    git checkout "${BRANCH_RTLSDR}" && \
    echo "rtl-sdr ${BRANCH_RTLSDR}" >> /VERSIONS && \
    mkdir -p /src/rtl-sdr/build && \
    cd /src/rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -Wno-dev && \
    # Fix broken pkg-config file...
    export LIBRTLSDR_PKGCONF_FILE="/src/rtl-sdr/build/librtlsdr.pc" && \
    sed -i "/^prefix=/c\prefix=/usr/local" "${LIBRTLSDR_PKGCONF_FILE}" && \
    sed -i "/^exec_prefix=/c\exec_prefix=\${prefix}" "${LIBRTLSDR_PKGCONF_FILE}" && \
    sed -i "/^libdir=/c\libdir=\${exec_prefix}/lib" "${LIBRTLSDR_PKGCONF_FILE}" && \
    sed -i "/^includedir=/c\includedir=\${prefix}/include" "${LIBRTLSDR_PKGCONF_FILE}" && \
    # =======
    make -Wstringop-truncation && \
    make -Wstringop-truncation install && \
    cp -v /src/rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/ && \
    echo "========== Blacklist RTL-SDR dongle ==========" && \
    echo "blacklist dvb_usb_rtl28xxu" >> /etc/modprobe.d/no-rtl.conf && \
    echo "blacklist rtl2832" >> /etc/modprobe.d/no-rtl.conf && \
    echo "blacklist rtl2830" >> /etc/modprobe.d/no-rtl.conf && \
    echo "========== Install bladeRF ==========" && \
    git clone --recursive https://github.com/Nuand/bladeRF.git /src/bladeRF && \
    cd /src/bladeRF && \
    export BRANCH_BLADERF=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_BLADERF} && \
    echo "bladeRF ${BRANCH_BLADERF}" >> /VERSIONS && \
    mkdir /src/bladeRF/host/build && \
    cd /src/bladeRF/host/build && \
    cmake -DTREAT_WARNINGS_AS_ERRORS=OFF ../ && \
    make && \
    make install && \
    echo "========== Install tcllauncher ==========" && \
    git clone https://github.com/flightaware/tcllauncher.git /src/tcllauncher && \
    export BRANCH_TCLLAUNCHER=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_TCLLAUNCHER} && \
    echo "tcllauncher ${BRANCH_TCLLAUNCHER}" >> /VERSIONS && \
    cd /src/tcllauncher && \
    autoconf && \
    ./configure --prefix=/opt/tcl && \
    make && \
    make install && \
    echo "========== Install tcllib ==========" && \
    git clone https://github.com/tcltk/tcllib.git /src/tcllib && \
    cd /src/tcllib && \
    export BRANCH_TCLLIB=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_TCLLIB} && \
    echo "tcllib ${BRANCH_TCLLIB}" >> /VERSIONS && \
    autoconf && \
    ./configure && \
    make && \
    make install && \
    echo "========== Install piaware ==========" && \
    git clone https://github.com/flightaware/piaware.git /src/piaware && \
    cd /src/piaware && \
    export BRANCH_PIAWARE=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_PIAWARE} && \
    echo "piaware ${BRANCH_PIAWARE}" >> /VERSIONS && \
    make && \
    make install && \
    cp -v /src/piaware/package/ca/*.pem /etc/ssl/ && \
    touch /etc/piaware.conf && \
    mkdir -p /run/piaware && \
    echo "========== Install dump1090 ==========" && \
    git clone https://github.com/flightaware/dump1090.git /src/dump1090 && \
    cd /src/dump1090 && \
    export BRANCH_DUMP1090=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_DUMP1090} && \
    echo "dump1090 ${BRANCH_DUMP1090}" >> /VERSIONS && \
    export LIBBLADERF_PKGCONF_DIR=$(dirname $(find / -type f -name libbladeRF.pc | grep -E "^/usr" | head -1)) && \
    export LIBRTLSDR_PKGCONF_DIR=$(dirname $(find / -type f -name librtlsdr.pc | grep -E "^/usr" | head -1)) && \
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$LIBBLADERF_PKGCONF_DIR:$LIBRTLSDR_PKGCONF_DIR" && \
    make all && \
    make faup1090 && \
    cp -v view1090 dump1090 /usr/local/bin/ && \
    cp -v faup1090 /usr/lib/piaware/helpers/ && \
    mkdir -p /run/dump1090-fa && \
    mkdir -p /usr/share/dump1090-fa/html && \
    cp -a /src/dump1090/public_html/* /usr/share/dump1090-fa/html/ && \
    echo "========== Install mlat-client ==========" && \
    git clone https://github.com/mutability/mlat-client.git /src/mlat-client && \
    cd /src/mlat-client && \
    export BRANCH_MLATCLIENT=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_MLATCLIENT} && \
    echo "mlat-client ${BRANCH_MLATCLIENT}" >> /VERSIONS && \
    ./setup.py install && \
    ln -s /usr/bin/fa-mlat-client /usr/lib/piaware/helpers/ && \
    echo "========== Install SoapySDR ==========" && \
    git clone https://github.com/pothosware/SoapySDR.git /src/SoapySDR && \
    cd /src/SoapySDR && \
    export BRANCH_SOAPYSDR=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_SOAPYSDR} && \
    echo "SoapySDR ${BRANCH_SOAPYSDR}" >> /VERSIONS && \
    mkdir -p /src/SoapySDR/build && \
    cd /src/SoapySDR/build && \
    cmake -Wno-dev .. && \
    make && \
    make install && \
    echo "========== Install dump978 ==========" && \
    git clone https://github.com/flightaware/dump978.git /src/dump978 && \
    cd /src/dump978 && \
    export BRANCH_DUMP978=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_DUMP978} && \
    echo "dump978 ${BRANCH_DUMP978}" >> /VERSIONS && \
    cd /src/dump978 && \
    make all && \
    make faup978 && \
    cp -v dump978-fa skyaware978 /usr/local/bin/ && \
    cp -v faup978 /usr/lib/piaware/helpers/ && \
    mkdir -p /usr/share/dump978-fa/html && \
    cp -a /src/dump978/skyaware/* /usr/share/dump978-fa/html/ && \
    echo "========== Install s6-overlay ==========" && \
    wget -q -O - https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    echo "========== Clean up build environment ==========" && \
    apk del \
    autoconf \
    cmake \
    g++ \
    gcc \
    git \
    gnupg \
    make \
    musl-dev \
    ncurses-dev \
    python3 \
    tcl-dev \
    && \
    rm -rf /var/cache/apk/* && \
    rm -rf /src && \
    echo "========== Done! =========="

COPY etc/ /etc/

EXPOSE 30104/tcp 8080/tcp 30001/tcp 30002/tcp 30003/tcp 30004/tcp 30005/tcp

ENTRYPOINT [ "/init" ]

# dump978 modifications to Makefile - not needed
#cp -v /src/dump978/Makefile /src/dump978/Makefile.original && \
#sed -i 's/CXXFLAGS+=-std=c++11 -Wall -Wno-psabi -Werror -O2 -g -Ilibs/CXXFLAGS+=-std=c++11 -Wall -Wno-psabi -Wno-error -O2 -g -Ilibs/' /src/dump978/Makefile && \
#sed -i 's/CFLAGS+=-Wall -Werror -O2 -g -Ilibs/CFLAGS+=-Wall -Wno-error -O2 -g -Ilibs/' /src/dump978/Makefile && \
