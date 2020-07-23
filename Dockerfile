FROM debian:stable-slim
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    DUMP1090_MAX_RANGE=400 \
    ALLOW_MODEAC=yes \
    ALLOW_MLAT=yes \
    RTLSDR_GAIN=-10 \
    RTLSDR_PPM=0 \
    BEASTPORT=30005 \
    BRANCH_RTLSDR="d794155ba65796a76cd0a436f9709f4601509320" \
    VERBOSE_LOGGING="false"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Note, the specific commit of rtlsdr is to address issue #15
# See: https://github.com/mikenye/docker-piaware/issues/15
# This should be revisited in future when rtlsdr 0.6.1 or newer is released

RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        autoconf \
        bash \
        ca-certificates \
        cmake \
        curl \
        file \
        gawk \
        g++ \
        gcc \
        git \
        gnupg \
        iproute2 \
        itcl3 \
        libboost-dev \
        libboost-filesystem1.67.0 \
        libboost-filesystem-dev \
        libboost-program-options1.67.0 \
        libboost-program-options-dev \
        libboost-regex1.67.0 \
        libboost-regex-dev \
        libboost-system1.67.0 \
        libboost-system-dev \
        libc-dev \
        libusb-1.0-0 \ 
        libusb-1.0-0-dev \
        lighttpd \
        make \
        ncurses-dev \
        net-tools \
        pkg-config \
        procps \
        python3 \
        python3-dev \
        python3-numpy \
        socat \
        swig \
        tcl \
        tcl-dev \
        tcl-tls \
        tclx \
        tzdata \
        wget \
        && \
    file -L /bin/cp && \
    git config --global advice.detachedHead false && \
    echo "========== Install RTL-SDR ==========" && \
    git clone git://git.osmocom.org/rtl-sdr.git /src/rtl-sdr && \
    pushd /src/rtl-sdr && \
    #BRANCH_RTLSDR=$(git tag --sort="-creatordate" | head -1) && \
    #git checkout tags/${BRANCH_RTLSDR} && \
    git checkout "${BRANCH_RTLSDR}" && \
    echo "rtl-sdr ${BRANCH_RTLSDR}" >> /VERSIONS && \
    mkdir -p /src/rtl-sdr/build && \
    popd && \
    pushd /src/rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -Wno-dev && \
    make -Wstringop-truncation && \
    make -Wstringop-truncation install && \
    ldconfig && \
    popd && \
    echo "========== Install bladeRF ==========" && \
    git clone --recursive https://github.com/Nuand/bladeRF.git /src/bladeRF && \
    pushd /src/bladeRF && \
    BRANCH_BLADERF="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_BLADERF}" && \
    echo "bladeRF ${BRANCH_BLADERF}" >> /VERSIONS && \
    mkdir /src/bladeRF/host/build && \
    popd && \
    pushd /src/bladeRF/host/build && \
    cmake \
        -DTREAT_WARNINGS_AS_ERRORS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        ../ \
        && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    echo "========== Downloading bladeRF FPGA Images ==========" && \
    BLADERF_RBF_PATH="/usr/share/Nuand/bladeRF" && \
    mkdir -p "$BLADERF_RBF_PATH" && \
    curl -o "$BLADERF_RBF_PATH/hostedxA4.rbf" https://www.nuand.com/fpga/hostedxA4-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedxA9.rbf" https://www.nuand.com/fpga/hostedxA9-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedx40.rbf" https://www.nuand.com/fpga/hostedx40-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedx115.rbf" https://www.nuand.com/fpga/hostedx115-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbxA4.rbf" https://www.nuand.com/fpga/adsbxA4.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbxA9.rbf" https://www.nuand.com/fpga/adsbxA9.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbx40.rbf" https://www.nuand.com/fpga/adsbx40.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbx115.rbf" https://www.nuand.com/fpga/adsbx115.rbf && \
    echo "========== Install tcllauncher ==========" && \
    git clone https://github.com/flightaware/tcllauncher.git /src/tcllauncher && \
    pushd /src/tcllauncher && \
    BRANCH_TCLLAUNCHER="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_TCLLAUNCHER}" && \
    echo "tcllauncher ${BRANCH_TCLLAUNCHER}" >> /VERSIONS && \
    autoconf && \
    ./configure --prefix=/opt/tcl && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    echo "========== Install tcllib ==========" && \
    git clone https://github.com/tcltk/tcllib.git /src/tcllib && \
    pushd /src/tcllib && \
    BRANCH_TCLLIB="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_TCLLIB}" && \
    echo "tcllib ${BRANCH_TCLLIB}" >> /VERSIONS && \
    autoconf && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    echo "========== Install piaware ==========" && \
    git clone https://github.com/flightaware/piaware.git /src/piaware && \
    pushd /src/piaware && \
    BRANCH_PIAWARE="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_PIAWARE}" && \
    echo "piaware ${BRANCH_PIAWARE}" >> /VERSIONS && \
    make && \
    make install && \
    cp -v /src/piaware/package/ca/*.pem /etc/ssl/ && \
    touch /etc/piaware.conf && \
    mkdir -p /run/piaware && \
    ldconfig && \
    popd && \
    echo "========== Install dump1090 ==========" && \
    git clone https://github.com/flightaware/dump1090.git /src/dump1090 && \
    pushd /src/dump1090 && \
    BRANCH_DUMP1090="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_DUMP1090}" && \
    echo "dump1090 ${BRANCH_DUMP1090}" >> /VERSIONS && \
    make all && \
    make faup1090 && \
    cp -v view1090 dump1090 /usr/local/bin/ && \
    cp -v faup1090 /usr/lib/piaware/helpers/ && \
    mkdir -p /run/dump1090-fa && \
    mkdir -p /usr/share/dump1090-fa/html && \
    cp -a /src/dump1090/public_html/* /usr/share/dump1090-fa/html/ && \
    ldconfig && \
    popd && \
    echo "========== Install mlat-client ==========" && \
    git clone https://github.com/mutability/mlat-client.git /src/mlat-client && \
    pushd /src/mlat-client && \
    BRANCH_MLATCLIENT="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_MLATCLIENT}" && \
    echo "mlat-client ${BRANCH_MLATCLIENT}" >> /VERSIONS && \
    ./setup.py install && \
    ln -s /usr/local/bin/fa-mlat-client /usr/lib/piaware/helpers/ && \
    ldconfig && \
    popd && \
    echo "========== Install SoapySDR ==========" && \
    git clone https://github.com/pothosware/SoapySDR.git /src/SoapySDR && \
    pushd /src/SoapySDR && \
    BRANCH_SOAPYSDR="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_SOAPYSDR}" && \
    echo "SoapySDR ${BRANCH_SOAPYSDR}" >> /VERSIONS && \
    mkdir -p /src/SoapySDR/build && \
    popd && \
    pushd /src/SoapySDR/build && \
    cmake -Wno-dev .. && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    echo "========== Install dump978 ==========" && \
    git clone https://github.com/flightaware/dump978.git /src/dump978 && \
    pushd /src/dump978 && \
    BRANCH_DUMP978="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_DUMP978}" && \
    echo "dump978 ${BRANCH_DUMP978}" >> /VERSIONS && \
    popd && \
    pushd /src/dump978 && \
    make all && \
    make faup978 && \
    cp -v dump978-fa skyaware978 /usr/local/bin/ && \
    cp -v faup978 /usr/lib/piaware/helpers/ && \
    mkdir -p /usr/share/dump978-fa/html && \
    cp -a /src/dump978/skyaware/* /usr/share/dump978-fa/html/ && \
    ldconfig && \
    popd && \
    echo "========== Install s6-overlay ==========" && \
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    echo "========== Clean up build environment ==========" && \
    apt-get remove -y \
        autoconf \
        cmake \
        curl \
        file \
        g++ \
        gcc \
        git \
        gnupg \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-regex-dev \
        libboost-system-dev \
        libc-dev \
        libusb-1.0-0-dev \
        make \
        ncurses-dev \
        pkg-config \
        python3-dev \
        tcl-dev \
        wget \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    echo "========== Testing ==========" && \
    ldconfig && \
    bladeRF-cli --version > /dev/null 2>&1 && \
    dump1090 --help > /dev/null 2>&1 && \
    mlat-client --help > /dev/null 2>&1 && \
    piaware -v > /dev/null 2>&1 && \
    SoapySDRUtil --info > /dev/null 2>&1 && \
    # dump978-fa --version > /dev/null 2>&1 && \
    echo "========== Done! =========="

COPY etc/ /etc/
COPY healthcheck.sh /healthcheck.sh

EXPOSE 30104/tcp 8080/tcp 30001/tcp 30002/tcp 30003/tcp 30004/tcp 30005/tcp

ENTRYPOINT [ "/init" ]

# HEALTHCHECK --start-period=30s --interval=300s CMD /healthcheck.sh
